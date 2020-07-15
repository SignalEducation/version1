# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class ResponseOptionsController < Api::V1::ApplicationController
        before_action :set_scenario, only: :create
        before_action :set_response_option, only: %i[update destroy]

        def create
          @response_option = @scenario.response_options.build(permitted_params)
          return if @response_option.save

          render json: { errors: @response_option.errors }, status: :unprocessable_entity
        end

        def update
          return if @response_option.update(permitted_params)

          render json: { errors: @response_option.errors }, status: :unprocessable_entity
        end

        def destroy
          return if @response_option.destroy

          render json: { errors: @response_option.errors }, status: :unprocessable_entity
        end

        private

        def permitted_params
          params.require(:response_options).permit(:content, :quantity, :sorting_order, :kind)
        end

        def set_scenario
          @scenario = Cbe::Scenario.find(params[:scenario_id])
        end

        def set_response_option
          @response_option = Cbe::ResponseOption.find(params[:id])
        end
      end
    end
  end
end
