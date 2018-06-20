module QA
  module Page
    module Project
      module Operations
        module Kubernetes
          class Add < Page::Base
            view 'app/views/projects/clusters/new.html.haml' do
              element :add_kubernetes_cluster_button, "link_to s_('ClusterIntegration|Add existing cluster')"
            end

            def add_existing_cluster
              click_on 'Add existing cluster'
            end
          end
        end
      end
    end
  end
end
