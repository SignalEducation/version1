# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::ApiController
      # before_action :authorize_user, only: :show
      before_action :set_user, only: :show

      def show
        render 'api/v1/users/show.json'
      end

      def create
        @user            = User.new(user_params)
        @user.country    = IpAddress.get_country(request.remote_ip, true)
        @user.currency   = @user&.country&.currency || Currency.find_by(iso_code: 'GBP')
        @user.user_group = UserGroup.student_group
        @user.user_registration_calbacks(params[:user])

        if @user.save && UserSession.create(@user)
          @user.handle_post_user_creation(user_verification_url(email_verification_code: @user.email_verification_code))
          @user_token       = encode_token(payload(@user))
          @user_credentials = session['user_credentials']

          render 'api/v1/users/show.json', status: :created
        else
          json_response({ error: @user.errors }, :unprocessable_entity)
        end
      end

      def forgot_password
        response = User.start_password_reset_process(params[:email])

        json_response(response[:json], response[:status])
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(
          :email, :first_name, :last_name, :preferred_exam_body_id, :country_id,
          :locale, :password, :password_confirmation, :terms_and_conditions,
          :communication_approval, :home_page_id
        )
      end
    end
  end
end
