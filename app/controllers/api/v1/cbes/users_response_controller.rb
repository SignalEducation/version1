# frozen_string_literal: true

module Api
  module V1
    module Cbes
      class UsersResponseController < Api::V1::ApplicationController
        def show
          @user_response = ::Cbe::UserResponse.find(params[:id])
        end
      end
    end
  end
end
