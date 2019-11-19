# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class ResourcesController < Api::V1::ApplicationController
        before_action :set_cbe
        before_action :set_resource, only: %i[update destroy]

        def index
          @resources = @cbe.resources
        end

        def create
          @resource = @cbe.resources.build(permitted_params)
          return if @resource.save

          render json: { errors: @resource.errors }, status: :unprocessable_entity
        end

        def update
          return if @resource.update(permitted_params)

          render json: { errors: @resource.errors }, status: :unprocessable_entity
        end

        def destroy
          @resource.destroy

          render json: { message: "Resource #{@resource.id} was deleted." }, status: :accepted
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

        def set_resource
          @resource = ::Cbe::Resource.find(params[:id])
        end
      end
    end
  end
end
