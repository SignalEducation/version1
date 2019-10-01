# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class SectionsController < Api::V1::ApplicationController
        def index
          @sections = ::Cbe::Section.all
        end

        def create
          @section = ::Cbe::Section.new(section_params)

          unless @section.save
            render json: { errors: @section.errors }, status: :unprocessable_entity
          end
        end

        def update
          @section = ::Cbe::Section.find(params[:id])

          unless @section.update(section_params)
            render json: { errors: @section.errors }, status: :unprocessable_entity
          end
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
      end
    end
  end
end
