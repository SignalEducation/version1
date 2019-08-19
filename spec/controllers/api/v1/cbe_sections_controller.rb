# frozen_string_literal: true

module Api
  module V1
    class CbeSectionsController < Api::V1::ApplicationController

      def create
        cbe_section = CbeSection.create(section_params)
        res = {cbeSectionId: cbe_section.id, cbeSectionName: cbe_section.name}
        render json: (res.as_json)
      end

      def index
        CbeSection.all
        to_json(:only => [:id, :name])
      end


      private

      def section_params
        params.require(:cbe_section).permit(:name, :scenario_label, :scenario_description, :cbe_id)
      end
    end
  end
end
