# frozen_string_literal: true

module Gitlab
  class SidekiqMigrateJobs
    LOG_FREQUENCY = 1_000

    attr_reader :logger, :mappings

    # mappings is a hash of WorkerClassName => target_queue_name
    def initialize(mappings, logger: nil)
      @mappings = mappings
      @logger = logger
    end

    # Migrate jobs in SortedSets, i.e. scheduled and retry sets.
    def migrate_set(sidekiq_set)
      source_queues_regex = Regexp.union(mappings.keys)
      cursor = 0
      scanned = 0
      migrated = 0

      estimated_size = Sidekiq.redis { |c| c.zcard(sidekiq_set) }
      logger&.info("Processing #{sidekiq_set} set. Estimated size: #{estimated_size}.")

      begin
        cursor, jobs = Sidekiq.redis { |c| c.zscan(sidekiq_set, cursor) }

        jobs.each do |(job, score)|
          if scanned > 0 && scanned % LOG_FREQUENCY == 0
            logger&.info("In progress. Scanned records: #{scanned}. Migrated records: #{migrated}.")
          end

          scanned += 1

          next unless job.match?(source_queues_regex)

          job_hash = Sidekiq.load_json(job)
          destination_queue = mappings[job_hash['class']]

          next unless mappings.has_key?(job_hash['class'])
          next if job_hash['queue'] == destination_queue

          job_hash['queue'] = destination_queue

          migrated += migrate_job_in_set(sidekiq_set, job, score, job_hash)
        end
      end while cursor.to_i != 0

      logger&.info("Done. Scanned records: #{scanned}. Migrated records: #{migrated}.")

      {
        scanned: scanned,
        migrated: migrated
      }
    end

    # Migrates jobs from queues that are outside the mappings
    def migrate_queues
      routing_rules_queues = mappings.values.uniq
      logger&.info("List of queues based on routing rules: #{routing_rules_queues}")
      Sidekiq.redis do |conn|
        # Redis 6 supports conn.scan_each(match: "queue:*", type: 'list')
        conn.scan_each(match: "queue:*") do |key|
          # Redis 5 compatibility
          next unless conn.type(key) == 'list'

          queue_from = key.split(':', 2).last
          next if routing_rules_queues.include?(queue_from)

          logger&.info("Migrating #{queue_from} queue")

          migrated = 0
          while queue_length(queue_from) > 0
            begin
              if migrated >= 0 && migrated % LOG_FREQUENCY == 0
                logger&.info("Migrating from #{queue_from}. Total: #{queue_length(queue_from)}. Migrated: #{migrated}.")
              end

              job = conn.rpop "queue:#{queue_from}"
              job_hash = Sidekiq.load_json job
              next unless mappings.has_key?(job_hash['class'])

              destination_queue = mappings[job_hash['class']]
              job_hash['queue'] = destination_queue
              conn.lpush("queue:#{destination_queue}", Sidekiq.dump_json(job_hash))
              migrated += 1
            rescue JSON::ParserError
              logger&.error("Unmarshal JSON payload from SidekiqMigrateJobs failed. Job: #{job}")
              next
            end
          end
          logger&.info("Finished migrating #{queue_from} queue")
        end
      end
    end

    private

    def migrate_job_in_set(sidekiq_set, job, score, job_hash)
      Sidekiq.redis do |connection|
        removed = connection.zrem(sidekiq_set, job)

        if removed
          connection.zadd(sidekiq_set, score, Sidekiq.dump_json(job_hash))

          1
        else
          0
        end
      end
    end

    def queue_length(queue_name)
      Sidekiq.redis do |conn|
        conn.llen("queue:#{queue_name}")
      end
    end
  end
end
