# frozen_string_literal: true

require 'mime/types'

module API
  class CommitStatuses < ::API::Base
    feature_category :continuous_integration
    urgency :low

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end
    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      include PaginationParams

      before { authenticate! }

      desc "Get a commit's statuses" do
        success Entities::CommitStatus
      end
      params do
        requires :sha,   type: String, desc: 'The commit hash'
        optional :ref,   type: String, desc: 'The ref'
        optional :stage, type: String, desc: 'The stage'
        optional :name,  type: String, desc: 'The name'
        optional :all,   type: String, desc: 'Show all statuses, default: false'
        use :pagination
      end
      # rubocop: disable CodeReuse/ActiveRecord
      get ':id/repository/commits/:sha/statuses' do
        authorize!(:read_commit_status, user_project)

        not_found!('Commit') unless user_project.commit(params[:sha])

        pipelines = user_project.ci_pipelines.where(sha: params[:sha])
        statuses = ::CommitStatus.where(pipeline: pipelines)
        statuses = statuses.latest unless to_boolean(params[:all])
        statuses = statuses.where(ref: params[:ref]) if params[:ref].present?
        statuses = statuses.where(stage: params[:stage]) if params[:stage].present?
        statuses = statuses.where(name: params[:name]) if params[:name].present?
        present paginate(statuses), with: Entities::CommitStatus
      end
      # rubocop: enable CodeReuse/ActiveRecord

      desc 'Post status to a commit' do
        success Entities::CommitStatus
      end
      params do
        requires :sha,         type: String,  desc: 'The commit hash'
        requires :state,       type: String,  desc: 'The state of the status',
                               values: %w(pending running success failed canceled)
        optional :ref,         type: String,  desc: 'The ref'
        optional :target_url,  type: String,  desc: 'The target URL to associate with this status'
        optional :description, type: String,  desc: 'A short description of the status'
        optional :name,        type: String,  desc: 'A string label to differentiate this status from the status of other systems. Default: "default"', documentation: { default: 'default' }
        optional :context,     type: String,  desc: 'A string label to differentiate this status from the status of other systems. Default: "default"', documentation: { default: 'default' }
        optional :coverage,    type: Float,   desc: 'The total code coverage'
        optional :pipeline_id, type: Integer, desc: 'An existing pipeline ID, when multiple pipelines on the same commit SHA have been triggered'
      end
      # rubocop: disable CodeReuse/ActiveRecord
      post ':id/statuses/:sha' do
        authorize! :create_commit_status, user_project

        not_found! 'Commit' unless commit

        # Since the CommitStatus is attached to ::Ci::Pipeline (in the future Pipeline)
        # We need to always have the pipeline object
        # To have a valid pipeline object that can be attached to specific MR
        # Other CI service needs to send `ref`
        # If we don't receive it, we will attach the CommitStatus to
        # the first found branch on that commit

        pipeline = all_matching_pipelines.first

        ref = params[:ref]
        ref ||= pipeline&.ref
        ref ||= user_project.repository.branch_names_contains(commit.sha).first
        not_found! 'References for commit' unless ref

        name = params[:name] || params[:context] || 'default'

        pipeline ||= user_project.ci_pipelines.build(
          source: :external,
          sha: commit.sha,
          ref: ref,
          user: current_user,
          protected: user_project.protected_for?(ref))

        pipeline.ensure_project_iid!
        pipeline.save!

        authorize! :update_pipeline, pipeline

        status = GenericCommitStatus.running_or_pending.find_or_initialize_by(
          project: user_project,
          pipeline: pipeline,
          name: name,
          ref: ref,
          user: current_user,
          protected: user_project.protected_for?(ref)
        )

        updatable_optional_attributes = %w[target_url description coverage]
        status.assign_attributes(attributes_for_keys(updatable_optional_attributes))

        render_validation_error!(status) unless status.valid?

        response = ::Ci::Pipelines::AddJobService.new(pipeline).execute!(status) do |job|
          apply_job_state!(job)
        rescue ::StateMachines::InvalidTransition => e
          render_api_error!(e.message, 400)
        end

        render_validation_error!(response.payload[:job]) unless response.success?

        if pipeline.latest?
          MergeRequest
            .where(source_project: user_project, source_branch: ref)
            .update_all(head_pipeline_id: pipeline.id)
        end

        present response.payload[:job], with: Entities::CommitStatus
      end
      # rubocop: enable CodeReuse/ActiveRecord

      helpers do
        def commit
          strong_memoize(:commit) do
            user_project.commit(params[:sha])
          end
        end

        def all_matching_pipelines
          pipelines = user_project.ci_pipelines.newest_first(sha: commit.sha)
          pipelines = pipelines.for_ref(params[:ref]) if params[:ref]
          pipelines = pipelines.for_id(params[:pipeline_id]) if params[:pipeline_id]
          pipelines
        end

        def apply_job_state!(job)
          case params[:state]
          when 'pending'
            job.enqueue!
          when 'running'
            job.enqueue
            job.run!
          when 'success'
            job.success!
          when 'failed'
            job.drop!(:api_failure)
          when 'canceled'
            job.cancel!
          else
            render_api_error!('invalid state', 400)
          end
        end
      end
    end
  end
end
