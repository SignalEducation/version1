# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class UsersLogController < Api::V1::ApplicationController
        before_action :set_user_log, only: :show

        def index
          @users_log = ::Cbe::UserLog.all
        end

        def show; end

        def create
          @user_log = ::Cbe::UserLog.new(permitted_params)

          unless @user_log.save
            render json: { errors: @user_log.errors }, status: :unprocessable_entity
          end
        end

        def update
          @user_log = ::Cbe::UserLog.find(params[:id])

          unless @user_log.update(permitted_params)
            render json: { errors: @user_log.errors }, status: :unprocessable_entity
          end
        end

        private

        def set_user_log
          @user_log = ::Cbe::UserLog.find(params[:id])
        end

        def permitted_params
          params.require(:cbe_user_log).permit(
            :status, :score, :created_at, :updated_at, :cbe_id, :user_id,
            answers_attributes: [
              :cbe_question_id, :cbe_answer_id,
              content: [
                :text, :correct, data: %i[value row col colBinding style]
              ]
            ]
          )
        end
      end
    end
  end
end
