# frozen_string_literal: true

module Api
  module V1
    class CbesController < Api::V1::ApplicationController

      def create
        cbe = Cbe.create(cbe_params)
        res = {cbeId: cbe.id, cbeName: cbe.name}
        render json: (res.as_json)
      end
    
      private
    
      def cbe_params
        params.require(:cbe).permit(:name, :title, :description, :subject_course_id, :time, :number_of_pauses, :length_of_pauses)
      end

    end
  end
end
