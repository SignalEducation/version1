# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'archivable' do
  let(:model) { described_class }
  let(:obj)   { model.new }

  describe '.destroy' do
    it 'model destroyed_at should be updated' do
      obj.destroy
      expect(obj.destroyed_at).not_to be_nil
    end
  end

  describe '.un_delete' do
    it 'model destroyed_at should be updated' do
      obj.un_delete
      expect(obj.destroyed_at).to be_nil
    end
  end
end
