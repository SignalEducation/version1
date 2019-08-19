# frozen_string_literal: true

module Api
    module V1
      class CbeQuestionTypesController < Api::V1::ApplicationController
        def index
          render json: CbeQuestionType.all.to_json(only: [:id, :name])
        end
      end
    end
  end