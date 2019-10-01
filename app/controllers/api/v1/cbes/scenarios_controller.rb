# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class ScenariosController < Api::V1::ApplicationController
        before_action :set_section

        def create
          @scenario = @section.scenarios.build(permitted_params)

          unless @scenario.save
            render json: { errors: @scenario.errors }, status: :unprocessable_entity
          end
        end

        def update
          @scenario = ::Cbe::Scenario.find(params[:id])

          unless @scenario.update(permitted_params)
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

        def set_section
          @section = ::Cbe::Section.find_by(id: params[:section_id])
        end
      end
    end
  end
end
