# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class UsersLogController < Api::V1::ApplicationController
        before_action :set_user_log, only: %i[show update user_agreement current_state]

        def index
          @users_log = ::Cbe::UserLog.all
        end

        def show; end

        def create
          @user_log = ::Cbe::UserLog.where(permitted_params).first_or_initialize

          return if @user_log.save

          render json: { errors: @user_log.errors }, status: :unprocessable_entity
        end

        def update
          # TODO: (giordano), questions are been duplicated
          @user_log.questions.destroy_all
          @user_log.responses.destroy_all

          return if @user_log.update(permitted_params)

          render json: { errors: @user_log.errors }, status: :unprocessable_entity
        end

        def user_agreement
          render update_user_log
        end

        def current_state
          render update_user_log
        end

        private

        def set_user_log
          @user_log = ::Cbe::UserLog.find(params[:id])
        end

        def update_user_log
          if @user_log.update(permitted_params)
            { json: { message: 'User log updated successfully.' }, status: :ok }
          else
            { json: { errors: @user_log.errors }, status: :unprocessable_entity }
          end
        end

        def permitted_params
          params.require(:cbe_user_log).permit(
            :status, :created_at, :updated_at, :cbe_id, :user_id,
            :exercise_id, :agreed, :current_state, :scratch_pad,
            pages_state: [
              :description,
              :state,
              :flagged,
              :type,
              :param,
              :page
            ],
            responses_attributes: [
              :cbe_response_option_id,
              content: {}
            ],
            questions_attributes: [
              :cbe_question_id, :score, :correct,
              answers_attributes: [
                :cbe_answer_id,
                :score,
                content: {}
              ]
            ]
          )
        end
      end
    end
  end
end
