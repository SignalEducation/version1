# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class ResourcesController < Api::V1::ApplicationController
        before_action :set_cbe

        def index
          @resources = @cbe.resources
        end

        def create
          @resource = @cbe.resources.build(permitted_params)

          unless @resource.save
            render json: { errors: @resource.errors }, status: :unprocessable_entity
          end
        end

        private

        def permitted_params
          params.require(:resource).permit(
            :name, :document, :sorting_order
          )
        end

        def set_cbe
          @cbe = Cbe.find(params[:cbe_id])
        end
      end
    end
  end
end
