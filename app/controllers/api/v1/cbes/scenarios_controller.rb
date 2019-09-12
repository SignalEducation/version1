# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class ScenariosController < Api::V1::ApplicationController

        def create
          @scenario = ::Cbe::Scenario.new(permitted_params)

          unless @scenario.save
            render json: { errors: @scenario.errors }, status: :unprocessable_entity
          end
        end

        private

        def permitted_params
          params.require(:scenario).permit(
            :content,
            :cbe_section_id
          )
        end
      end
    end
  end
end
