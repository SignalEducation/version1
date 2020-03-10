# frozen_string_literal: true

module Filterable
  extend ActiveSupport::Concern

  included do
    @search_scopes ||= []
  end

  module ClassMethods
    attr_reader :search_scopes

    def search_scope(name, *args)
      scope name, *args
      @search_scopes << name
    end

    def filter_from_params(filtering_params)
      unless filtering_params.is_a? ActionController::Parameters
        raise ArgumentError, 'The filtering params arguement must be a hash'
      end

      results = where(nil)
      filtering_params.each do |key, value|
        results = results.public_send(key, value) if value.present?
      end
      results
    end
  end
end
