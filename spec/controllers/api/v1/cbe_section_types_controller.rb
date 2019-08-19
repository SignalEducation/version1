# frozen_string_literal: true

module Api
    module V1
      class CbeSectionTypesController < Api::V1::ApplicationController
        def index
          render json: Cbe.all.to_json(only: [:id, :name])
        end
      end
    end
  end