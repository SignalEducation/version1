# frozen_string_literal: true

module Api
  module V1
    class AuthController < Api::V1::ApiController
      before_action :set_user, only: :login

      def login
        return json_response({ error: 'No user registered with this email.' }, :not_found) unless @user

        @user_session = UserSession.new(user_params.to_h)

        if @user_session.save
          @user_token       = encode_token(payload(@user))
          @user_credentials = session['user_credentials']

          render 'api/v1/users/show.json'
        else
          json_response({ error: 'Invalid password.' }, :unprocessable_entity)
        end
      end

      def logout; end

      private

      def set_user
        @user = User.find_by(email: user_params[:email])
      end

      def user_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
