class UserVerificationsController < ApplicationController

  def update

    @user = User.get_and_verify(params[:email_verification_code])
    if @user && @user.password_change_required?
      @user.update_attributes(password_reset_requested_at: Time.now, password_reset_token: SecureRandom.hex(10))
      set_password_url = set_password_url(id: @user.password_reset_token)
      redirect_to set_password_url
    elsif @user
      UserSession.create(@user)
      redirect_to account_verified_url
      subscribe_to_mailchimp(@user.email, @user.first_name, @user.last_name) if @user.individual_student?
    else
      flash[:error] = I18n.t('controllers.user_activations.update.error')
      redirect_to subscription_groups_url
    end
  end

  def old_mail_activation
    @user = User.get_and_verify(params[:email_verification_code])
    if @user && @user.password_change_required?
      @user.update_attributes(password_reset_requested_at: Time.now,
                              password_reset_token: SecureRandom.hex(10),
                              account_activated_at: Time.now,
                              account_activation_code: nil,
                              active: true
      )
      reset_password_url = reset_password_url(id: @user.password_reset_token)
      redirect_to reset_password_url
    elsif @user
      @user.update_attributes(account_activated_at: Time.now,
                              account_activation_code: nil,
                              active: true)
      UserSession.create(@user)
      redirect_to subscription_groups_url
    else
      flash[:error] = I18n.t('controllers.user_activations.update.error')
      redirect_to subscription_groups_url
    end

  end

  def subscribe_to_mailchimp(email, first_name, last_name)
    list_id = ENV['learnsignal_mailchimp_list_id']
    begin
      @mc.lists.subscribe(list_id, {'email' => email, 'status' => 'subscribed', 'send_welcome' => false, 'double_optin' => false, 'merge_fields' => {'FNAME' => first_name, 'LNAME' => last_name}})
      Rails.logger.debug "Mailchimp: User with #{email} was successfully subscribed to the list #{list_id} on mailchimp."
    rescue Mailchimp::ListAlreadySubscribedError
      Rails.logger.error "Mailchimp: User with #{email} was not subscribed to the list #{list_id} on mailchimp. Because the email is already present in the list"
    rescue Mailchimp::ListDoesNotExistError
      Rails.logger.error "Mailchimp: User with #{email} was not subscribed to the list #{list_id} on mailchimp. Because their is no list with the ID #{list_id}"
      return
    rescue Mailchimp::Error => ex
      if ex.message
        Rails.logger.error "Mailchimp: User with #{email} was not subscribed to the list #{list_id} on mailchimp. Because #{ex.message}"
      else
        Rails.logger.error "Mailchimp: User with #{email} was not subscribed to the list #{list_id} on mailchimp. Because of an unknown error"
      end
    end
    return
  end

end
