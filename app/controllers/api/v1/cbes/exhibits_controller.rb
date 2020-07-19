# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class ExhibitsController < Api::V1::ApplicationController
        before_action :format_spreadsheet
        before_action :set_scenario

        def create
          @exhibit = @scenario.exhibits.build(permitted_params)
          return if @exhibit.save

          render json: { errors: @exhibit.errors }, status: :unprocessable_entity
        end

        private

        def format_spreadsheet
          return if params[:exibits][:content].blank?

          params[:exibits][:content] = JSON.parse(params[:exibits][:content])
        end

        def permitted_params
          params.require(:exibits).permit(
            :name, :document, :sorting_order, :kind,
            content: {}
          )
        end

        def set_scenario
          @scenario = Cbe::Scenario.find(params[:scenario_id])
        end
      end
    end
  end
end
