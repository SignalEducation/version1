# frozen_string_literal: true

module Api
  module V1
    module Cbe
      class ScenariosController < Api::V1::ApplicationController

        def create

          @scenario = ::Cbe::Scenario.new(permitted_params)

          if @scenario.save
            render 'api/v1/cbe/scenarios/show.json'
          else
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
