# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class IntroductionPagesController < Api::V1::ApplicationController
        def index
          @pages = ::Cbe::IntroductionPage.all
        end

        def create
          @page = ::Cbe::IntroductionPage.new(introduction_page_params)

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
            :title, :content, :sorting_order, :cbe_id, :kind
          )
        end
      end
    end
  end
end
