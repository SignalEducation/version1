# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::ApiController
      def create
        user            = User.new(user_params)
        user.country    = IpAddress.get_country(request.remote_ip, true)
        user.currency   = @user&.country&.currency || Currency.find_by(iso_code: 'GBP')
        user.user_group = UserGroup.student_group
        user.user_registration_calbacks(params)

        if user.save
          user.handle_post_user_creation

          json_response({ message: 'User successfully created.' }, :created)
        else
          json_response({ error: user.errors }, :unprocessable_entity)
        end
      end

      private

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
