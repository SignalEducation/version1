# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class RequirementsController < Api::V1::ApplicationController
        before_action :set_scenario, only: :create
        before_action :set_requirement, only: %i[update destroy]

        def create
          @requirement = @scenario.requirements.build(permitted_params)
          return if @requirement.save

          render json: { errors: @requirement.errors }, status: :unprocessable_entity
        end

        def update
          return if @requirement.update(permitted_params)

          render json: { errors: @requirement.errors }, status: :unprocessable_entity
        end

        def destroy
          if @requirement.destroy
            render json: { message: "Requirement #{@requirement.id} was deleted." }, status: :accepted
          else
            render json: { errors: @requirement.errors }, status: :unprocessable_entity
          end
        end

        private

        def permitted_params
          params.require(:requirements).permit(
            :name, :content, :solution, :score, :sorting_order, :kind
          )
        end

        def set_scenario
          @scenario = Cbe::Scenario.find(params[:scenario_id])
        end

        def set_requirement
          @requirement = Cbe::Requirement.find(params[:id])
        end
      end
    end
  end
end
