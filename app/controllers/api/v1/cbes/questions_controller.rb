# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class QuestionsController < Api::V1::ApplicationController
        before_action :set_parent
        before_action :set_question, only: %i[update destroy]

        def index
          @questions = @parent.questions.order(:sorting_order)
        end

        def create
          @question = @parent.questions.build(permitted_params)

          return if @question.save

          render json: { errors: @question.errors }, status: :unprocessable_entity
        end

        def update
          records_to_be_destroyed(@question.answers, permitted_params[:answers_attributes])

          return if @question.update(permitted_params)

          render json: { errors: @question.errors }, status: :unprocessable_entity
        end

        def destroy
          @question.destroy

          render json: { message: "Question #{@question.id} was deleted." }, status: :accepted
        end

        private

        def permitted_params
          params.require(:question).permit(
            :kind, :content, :score, :sorting_order, :cbe_scenario_id, :cbe_section_id, :solution,
            answers_attributes: [
              :id, :cbe_question_id, :kind, :_destroy,
              content: [
                :text, :correct, data: %i[value row col colBinding style]
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

        def set_question
          @question = ::Cbe::Question.find(params[:id])
        end

        # Update permitted_params to add records to be destroyed.
        def records_to_be_destroyed(question_answers, answers)
          current_ids    = answers.map { |a| a[:id] }.compact
          ids_to_destroy = question_answers.where.not(id: current_ids).pluck(:id)

          ids_to_destroy.each do |id|
            params[:question][:answers_attributes] << { id: id, _destroy: true }
          end
        end
      end
    end
  end
end
