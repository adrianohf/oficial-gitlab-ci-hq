# frozen_string_literal: true

module Integrations
  class Slack < BaseChatNotification
    include SlackMattermostNotifier

    SUPPORTED_EVENTS_FOR_USAGE_LOG = %w[
      push issue confidential_issue merge_request note confidential_note
      tag_push wiki_page deployment
    ].freeze
    SNOWPLOW_EVENT_CATEGORY = self.name

    prop_accessor EVENT_CHANNEL['alert']

    def title
      'Slack notifications'
    end

    def description
      'Send notifications about project events to Slack.'
    end

    def self.to_param
      'slack'
    end

    def default_channel_placeholder
      _('#general, #development')
    end

    def webhook_placeholder
      'https://hooks.slack.com/services/…'
    end

    def supported_events
      additional = []
      additional << 'alert'

      super + additional
    end

    def get_message(object_kind, data)
      return Integrations::ChatMessage::AlertMessage.new(data) if object_kind == 'alert'

      super
    end

    override :log_usage
    def log_usage(event, user_id)
      return unless user_id

      return unless SUPPORTED_EVENTS_FOR_USAGE_LOG.include?(event)

      key = "i_ecosystem_slack_service_#{event}_notification"

      Gitlab::UsageDataCounters::HLLRedisCounter.track_event(key, values: user_id)

      return unless Feature.enabled?(:route_hll_to_snowplow_phase2)

      optional_arguments = {
        project: project,
        namespace: group || project&.namespace
      }.compact

      Gitlab::Tracking.event(
        SNOWPLOW_EVENT_CATEGORY,
        Integration::SNOWPLOW_EVENT_ACTION,
        label: Integration::SNOWPLOW_EVENT_LABEL,
        property: key,
        user: User.find(user_id),
        **optional_arguments
      )
    end

    override :configurable_channels?
    def configurable_channels?
      true
    end
  end
end
