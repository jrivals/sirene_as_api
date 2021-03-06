require 'rails_helper'

describe DailyUpdate::Task::AdaptApiResults, :trb do
  subject { described_class.call model: model, api_results: api_results, logger: logger }

  let(:logger) { instance_spy Logger }
  let(:api_results) { [item_1, item_2] }
  let(:item_1) { item }
  let(:item_2) { item }

  def item
    JSON.parse(
      File.read(fixture_path),
      symbolize_names: true
    )
  end

  describe 'Etablissement' do
    let(:model) { Etablissement }
    let(:fixture_path) { 'spec/fixtures/samples_insee/etablissement.json' }

    it { is_expected.to be_success }

    it 'calls AdaptEtablissement twice' do
      expect_to_call_nested_operation(DailyUpdate::Task::AdaptEtablissement).twice
      subject
    end

    its([:results]) { is_expected.to have_attributes(count: 2) }

    it 'returns results in hash' do
      expect(subject[:results]).to all be_a(Hash)
    end
  end

  describe 'UniteLegale' do
    let(:model) { UniteLegale }
    let(:fixture_path) { 'spec/fixtures/samples_insee/unite_legale.json' }

    it { is_expected.to be_success }

    it 'calls AdaptUniteLegale twice' do
      expect_to_call_nested_operation(DailyUpdate::Task::AdaptUniteLegale).twice
      subject
    end

    its([:results]) { is_expected.to have_attributes(count: 2) }

    it 'returns results in hash' do
      expect(subject[:results]).to all be_a(Hash)
    end
  end
end
