# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ml::Candidate, factory_default: :keep do
  let_it_be(:candidate) { create(:ml_candidates, :with_metrics_and_params) }

  describe 'associations' do
    it { is_expected.to belong_to(:experiment) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:params) }
    it { is_expected.to have_many(:metrics) }
  end

  describe '.artifact_root' do
    subject { candidate.artifact_root }

    it { is_expected.to eq("/ml_candidate_#{candidate.iid}/-/") }
  end

  describe '#new' do
    it 'iid is not null' do
      expect(candidate.iid).not_to be_nil
    end
  end

  describe '#by_project_id_and_iid' do
    let(:project_id) { candidate.experiment.project_id }
    let(:iid) { candidate.iid }

    subject { described_class.with_project_id_and_iid(project_id, iid) }

    context 'when iid exists', 'and belongs to project' do
      it { is_expected.to eq(candidate) }
    end

    context 'when iid exists', 'and does not belong to project' do
      let(:project_id) { non_existing_record_id }

      it { is_expected.to be_nil }
    end

    context 'when iid does not exist' do
      let(:iid) { 'a' }

      it { is_expected.to be_nil }
    end
  end
end
