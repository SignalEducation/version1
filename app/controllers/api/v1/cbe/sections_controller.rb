# frozen_string_literal: true
module Api
  module V1
    module Cbe
      class SectionsController < Api::V1::ApplicationController
        def index
          @sections = ::Cbe::Section.all
        end

        def update
        end

        def show
        end

        def create
          @section = ::Cbe::Section.new(section_params)

          if @section.save
            render 'api/v1/cbe/sections/show.json'
          else
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
