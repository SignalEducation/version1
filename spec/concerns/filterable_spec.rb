# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'filterable' do
  let(:model) { described_class }

  describe '.search_scopes' do
    it 'returns and array of search scopes' do
      expect(model.search_scopes).to be_kind_of Array
    end
  end

  describe '.filter' do
    it 'implements the filter class method' do
      expect(model).to respond_to :filter
    end

    it 'is raises an error if the first argument is not a hash' do
      expect { model.filter('string') }.to(
        raise_error(ArgumentError)
      )
    end

    it 'calls the relevant scope on the model if a value is present' do
      expect(model).to receive(model.search_scopes.first)

      model.filter(
        ActionController::Parameters.new(
          model.search_scopes.first.to_sym => 'test'
        )
      )
    end

    it 'does not call a scope if a value is not present' do
      expect(model).not_to receive(model.search_scopes.first)

      model.filter(
        ActionController::Parameters.new(
          model.search_scopes.first.to_sym => ''
        )
      )
    end

    it 'returns an ActiveRecord::Relation' do
      expect(
        model.filter(
          ActionController::Parameters.new(
            model.search_scopes.first.to_sym => 'test'
          )
        )
      ).to be_kind_of ActiveRecord::Relation
    end
  end
end
