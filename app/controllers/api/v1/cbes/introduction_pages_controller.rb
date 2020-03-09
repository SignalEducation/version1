# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class IntroductionPagesController < Api::V1::ApplicationController
        before_action :set_cbe, only: %i[index create update]
        before_action :set_page, only: %i[update destroy]

        def index
          @pages = @cbe.introduction_pages
        end

        def create
          @page = @cbe.introduction_pages.build(introduction_page_params)
          return if @page.save

          render json: { errors: @page.errors }, status: :unprocessable_entity
        end

        def update
          return if @page.update(introduction_page_params)

          render json: { errors: @page.errors }, status: :unprocessable_entity
        end

        def destroy
          if @page.destroy
            render json: { message: "Page #{@page.id} was deleted." }, status: :accepted
          else
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

        def set_page
          @page = ::Cbe::IntroductionPage.find(params[:id])
        end
      end
    end
  end
end
