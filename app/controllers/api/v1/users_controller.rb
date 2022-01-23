# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::ApiController
      before_action :set_user, only: %i[show update change_password resend_verify_user_email]
      before_action :set_user_id, only: %i[update change_password]
      before_action :authorize_user, only: %i[update change_password]
      before_action :same_user?, only: %i[update change_password]

      def show
        render 'api/v1/users/show.json'
      end

      def create
        @user            = User.new(user_params)
        @user.country    = user_country(@user, params[:iso_code])
        @user.currency   = @user&.country&.currency || Currency.find_by(iso_code: 'GBP')
        @user.user_group = UserGroup.student_group
        @user.user_registration_calbacks(params[:user])

        if @user.save
          @user.handle_post_user_creation(user_verification_url(email_verification_code: @user.email_verification_code))
          @user_token       = encode_token(payload(@user))
          @user_credentials = "#{session['user_credentials']}::#{session['user_credentials_id']}" if UserSession.create(@user)

          SegmentService.new.track_user_account_created_event(@user, session&.id, analytics_attributes_params&.to_h) if params[:analytics_attributes].present?

          render 'api/v1/users/show.json', status: :created
        else
          json_response({ error: @user.errors }, :unprocessable_entity)
        end
      end

      def update
        if @user.update(user_params)
          render 'api/v1/users/show.json', status: :ok
        else
          json_response({ error: @user.errors }, :unprocessable_entity)
        end
      end

      def forgot_password
        response = User.start_password_reset_process(params[:email])

        json_response(response[:json], response[:status])
      end

      def change_password
        if @user.change_the_password(change_password_params)
          json_response({ message: I18n.t('controllers.users.change_password.flash.success') }, :ok)
        else
          json_response({ message: I18n.t('controllers.users.change_password.flash.error') }, :unprocessable_entity)
        end
      end

      def resend_verify_user_email
        url = user_verification_url(email_verification_code: @user.email_verification_code)

        if @user.send_verification_email(url)
          json_response({ message: "A verification email was sent to #{@user.email}." }, :ok)
        else
          json_response({ error: "An error ocurred when tried to send e verification email to #{@user.email}." }, :unprocessable_entity)
        end
      end

      private

      def set_user
        @user = User.find(params[:id] || params[:user_id])
      end

      def set_user_id
        @user_id = (params[:id] || params[:user_id]).to_i
      end

      def same_user?
        return if @current_user.id == @user_id

        json_response({ error: 'You are not allowed to update this user.' }, :unauthorized)
      end

      def user_country(user, iso_code)
        country =
          if iso_code.present?
            Country.find_by(iso_code: iso_code.upcase) || Country.find_by(name: 'United Kingdom')
          else
            IpAddress.get_country(request.remote_ip) || Country.find_by(name: 'United Kingdom')
          end

        country
      end

      def user_params
        params.require(:user).permit(
          :email, :first_name, :last_name, :preferred_exam_body_id, :country_id,
          :locale, :password, :password_confirmation, :terms_and_conditions,
          :communication_approval, :home_page_id, :date_of_birth, :analytics_attributes
        )
      end

      def analytics_attributes_params
        params.require(:analytics_attributes).permit!
      end

      def change_password_params
        params.require(:user).permit(:current_password, :password, :password_confirmation)
      end
    end
  end
end
