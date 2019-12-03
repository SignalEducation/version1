# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class SectionsController < Api::V1::ApplicationController
        before_action :set_section, only: %i[update destroy]

        def index
          @sections = ::Cbe::Section.all
        end

        def create
          @section = ::Cbe::Section.new(section_params)

          return if  @section.save

          render json: { errors: @section.errors }, status: :unprocessable_entity
        end

        def update
          return if @section.update(section_params)

          render json: { errors: @section.errors }, status: :unprocessable_entity
        end

        def destroy
          @section.destroy

          render json: { message: "Section #{@section.id} was deleted." }, status: :accepted
        end

        private

        def section_params
          params.require(:cbe_section).permit(:name,
                                              :score,
                                              :kind,
                                              :sorting_order,
                                              :content,
                                              :cbe_id)
        end

        def set_section
          @section = ::Cbe::Section.find(params[:id])
        end
      end
    end
  end
end
