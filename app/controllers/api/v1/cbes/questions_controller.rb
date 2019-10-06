# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class QuestionsController < Api::V1::ApplicationController
        before_action :set_parent

        def index
          @questions = @parent.questions.order(:sorting_order)
        end

        def create
          @question = @parent.questions.build(permitted_params)

          unless @question.save
            render json: { errors: @question.errors }, status: :unprocessable_entity
          end
        end

        def update
          @question = ::Cbe::Question.find(params[:id])

          unless @question.update(permitted_params)
            render json: { errors: @question.errors }, status: :unprocessable_entity
          end
        end

        private

        def permitted_params
          params.require(:question).permit(
            :kind,
            :content,
            :score,
            :cbe_scenario_id,
            :cbe_section_id,
            answers_attributes: [
              :cbe_question_id,
              :kind,
              content: [
                :text,
                :correct
              ]
            ]
          )
        end

        def set_parent
          @parent = if params[:section_id].present?
                      ::Cbe::Section.find_by(id: params[:section_id])
                    elsif params[:scenario_id].present?
                      ::Cbe::Scenario.find_by(id: params[:scenario_id])
                    end
        end
      end
    end
  end
end
