# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'cbe_support' do
  let(:model) { described_class }
  let(:obj)   { model.new }

  describe '.destroy' do
    it 'model destroyed_at should be updated' do
      obj.destroy
      expect(obj.destroyed_at).not_to be_nil
      expect(obj.destroyed_at).not_to be_falsey
    end
  end
end
