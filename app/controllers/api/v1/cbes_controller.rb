# frozen_string_literal: true

module Api
  module V1
    class CbesController < Api::V1::ApplicationController

      def new
        SubjectCourse.all.pluck(:id, :name)
      end
    
      def index
      end

      def show
       # render json: Cbe.first
      end
      
      def create_section
        cbe_section = CbeSection.create(section_params)  
        res = {cbeSectionId: cbe_section.id, cbeSectionName: cbe_section.name}
        render json: (res.as_json)
      end
    
      def create
        cbe = Cbe.create(cbe_params)
        res = {cbeId: cbe.id, cbeName: cbe.name}
        render json: (res.as_json)
      end
    
      def question_types
        res = CbeQuestionType.all.to_json(only: [:id, :name])
        render json: (res)
      end
    
      def question_statuses
        res = CbeQuestionStatus.all.to_json(only: [:id, :name])
        render json: (res)
      end
    
      def section_types
        res = CbeSectionType.all.to_json(only: [:id, :name])
        render json: (res)
      end
    
    
      private
    
      def cbe_params
        params.require(:cbe).permit(:name, :title, :description, :subject_course_id, :time, :number_of_pauses, :length_of_pauses)
      end
    
    
      def section_params
        params.require(:cbe_section).permit(:name, :scenario_label, :scenario_description, :cbe_id)
      end
    end
  end
end
