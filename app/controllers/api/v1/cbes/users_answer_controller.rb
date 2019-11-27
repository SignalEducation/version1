# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class UsersAnswerController < Api::V1::ApplicationController
        def show
          @user_answer = ::Cbe::UserAnswer.find(params[:id])
        end
      end
    end
  end
end
