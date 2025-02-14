# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        class Populate < Chain::Base
          include Chain::Helpers

          PopulateError = Class.new(StandardError)

          def perform!
            raise ArgumentError, 'missing pipeline seed' unless @command.pipeline_seed

            ##
            # Populate pipeline with all stages, and stages with builds.
            #
            pipeline.stages = @command.pipeline_seed.stages

            if stage_names.empty?
              return error('No stages / jobs for this pipeline.')
            end

            if pipeline.invalid?
              return error('Failed to build the pipeline!')
            end

            set_pipeline_name

            raise Populate::PopulateError if pipeline.persisted?
          end

          def break?
            pipeline.errors.any?
          end

          private

          def set_pipeline_name
            return if Feature.disabled?(:pipeline_name, pipeline.project) ||
              @command.yaml_processor_result.workflow_name.blank?

            name = @command.yaml_processor_result.workflow_name
            name = ExpandVariables.expand(name, -> { global_context.variables.sort_and_expand_all })

            pipeline.build_pipeline_metadata(project: pipeline.project, name: name)
          end

          def global_context
            Gitlab::Ci::Build::Context::Global.new(
              pipeline, yaml_variables: @command.pipeline_seed.root_variables)
          end

          def stage_names
            # We filter out `.pre/.post` stages, as they alone are not considered
            # a complete pipeline:
            # https://gitlab.com/gitlab-org/gitlab/issues/198518
            pipeline.stages.map(&:name) - ::Gitlab::Ci::Config::EdgeStagesInjector::EDGES
          end
        end
      end
    end
  end
end
