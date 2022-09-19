# frozen_string_literal: true

RSpec.shared_examples 'requires feature flag `incubation_5mp_google_cloud` enabled' do
  context 'when feature flag is disabled' do
    before do
      project.add_maintainer(user)
      stub_feature_flags(incubation_5mp_google_cloud: false)
    end

    it 'renders not found' do
      sign_in(user)

      subject

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end
end
