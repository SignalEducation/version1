# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class ScenariosController < Api::V1::ApplicationController
        before_action :set_section
        before_action :set_scenario, only: %i[update destroy]

        def create
          @scenario = @section.scenarios.build(permitted_params)

          return if @scenario.save

          render json: { errors: @scenario.errors }, status: :unprocessable_entity
        end

        def update
          @scenario = ::Cbe::Scenario.find(params[:id])

          return if @scenario.update(permitted_params)

          render json: { errors: @scenario.errors }, status: :unprocessable_entity
        end

        def show
          @scenario = ::Cbe::Scenario.find(params[:id])
        end

        def destroy
          if @scenario.destroy
            render json: { message: "Scenario #{@scenario.id} was deleted." }, status: :accepted
          else
            render json: { errors: @scenario.errors }, status: :unprocessable_entity
          end
        end

        private

        def permitted_params
          params.require(:scenario).permit(
            :name,
            :content,
            :cbe_section_id
          )
        end

        def set_section
          @section = ::Cbe::Section.find_by(id: params[:section_id])
        end

        def set_scenario
          @scenario = ::Cbe::Scenario.find(params[:id])
        end
      end
    end
  end
end
