# frozen_string_literal: true

module Api
    module V1
      class CbeSectionTypesController < Api::V1::ApplicationController
        def index
          render json: CbeSectionType.all.to_json(only: [:id, :name])
        end
      end
    end
  end