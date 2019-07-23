# frozen_string_literal: true

module Api
  module V1
    class CbeSectionsController < Api::V1::ApplicationController

      def create
        puts "**** IN SECTION CREATE ****"
        cbe_section = CbeSection.create(section_params)
        puts cbe_section.errors.messages
        
        res = {cbeSectionId: cbe_section.id, cbeSectionName: cbe_section.name}
        puts "**** RES --- #{res}"
        render json: (res.as_json)
      end

      private

      def section_params
        params.require(:cbe_section).permit(:name, :scenario_label, :scenario_description, :cbe_id)
      end
    end
  end
end
