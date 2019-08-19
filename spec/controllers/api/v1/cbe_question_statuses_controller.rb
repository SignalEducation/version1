# frozen_string_literal: true

module Api
    module V1
      class CbeQuestionStatusesController < Api::V1::ApplicationController
        def index
          render json: CbeQuestionStatus.all.to_json(only: [:id, :name])
        end
      end
    end
  end