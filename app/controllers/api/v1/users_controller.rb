# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::ApplicationController
      def show; end

      def create
        user_country = IpAddress.get_country(request.remote_ip, true)
        user_currency = user_country&.currency || Currency.find_by(iso_code: 'GBP')

        # move this merge piece to a method.
        user = User.new(
          user_params.merge(
            user_group: UserGroup.student_group,
            country: user_country,
            currency: user_currency
          )
        )

        binding.pry
        if user.save
          handle_post_user_creation(user)
          render json: { message: 'User created.' }, status: :ok
        else
          render json: { errors: user.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(user_params)
          render json: { message: 'User updated.' }, status: :ok
        else
          render json: { errors: @user.errors }, status: :unprocessable_entity
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

      # move it to other place and user it in student sign up
      def handle_post_user_creation(user)
        user.set_analytics(cookies[:_ga])
        user.activate_user
        user.create_stripe_customer
        user.send_verification_email(
          user_verification_url(email_verification_code: user.email_verification_code)
        )
        user.validate_referral(cookies.encrypted[:referral_data])
        cookies.delete(:referral_data)
      end
    end
  end
end
