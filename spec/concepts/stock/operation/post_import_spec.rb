require 'rails_helper'

describe Stock::Operation::PostImport, :trb do
  subject { described_class.call logger: logger }

  let(:logger) { instance_spy Logger }

  shared_examples 'not doing anything' do
    it { is_expected.to be_success }

    it 'logs other import not finished' do
      subject
      expect(logger).to have_received(:info).with('Other import not finished')
    end

    it 'does not create relationship' do
      subject
      expect_not_to_call_nested_operation(Stock::Task::CreateAssociations)
    end

    it 'does not create database indexes' do
      expect_not_to_call_nested_operation(Stock::Task::CreateIndexes)
      subject
    end
  end

  context 'when StockEtablissement is not COMPLETED' do
    before do
      create :stock_etablissement, :pending
      create :stock_unite_legale, :completed
    end

    it_behaves_like 'not doing anything'
  end

  context 'when StockUniteLegale is not completed' do
    before do
      create :stock_etablissement, :completed
      create :stock_unite_legale, :loading
    end

    it_behaves_like 'not doing anything'
  end

  context 'when StockUniteLegale does not exists' do
    it_behaves_like 'not doing anything'
  end

  context 'when StockEtablissement does not exists' do
    before { create :stock_unite_legale, :completed }

    it_behaves_like 'not doing anything'
  end

  context 'when both imports are COMPLETED' do
    before do
      create :stock_etablissement, :completed
      create :stock_unite_legale, :completed
    end

    it { is_expected.to be_success }

    it 'created the association' do
      expect_to_call_nested_operation(Stock::Task::CreateAssociations)
      subject
    end

    it 'swaps table names' do
      expect_to_call_nested_operation(Stock::Task::SwapTableNames)
      subject
    end

    it 'drops indexes' do
      expect_to_call_nested_operation(Stock::Task::DropIndexes)
      subject
    end

    it 'creates database indexes' do
      expect_to_call_nested_operation(Stock::Task::CreateIndexes)
      subject
    end
  end
end
