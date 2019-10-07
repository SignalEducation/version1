# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class IntroductionPagesController < Api::V1::ApplicationController
        before_action :set_cbe

        def index
          @pages = @cbe.introduction_pages
        end

        def create
          @page = @cbe.introduction_pages.build(introduction_page_params)

          unless @page.save
            render json: { errors: @page.errors }, status: :unprocessable_entity
          end
        end

        def update
          @page = ::Cbe::IntroductionPage.find(params[:id])

          unless @page.update(introduction_page_params)
            render json: { errors: @page.errors }, status: :unprocessable_entity
          end
        end

        private

        def introduction_page_params
          params.require(:cbe_introduction_page).permit(
            :title, :content, :sorting_order
          )
        end

        def set_cbe
          @cbe = Cbe.find(params[:cbe_id])
        end
      end
    end
  end
end
