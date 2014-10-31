class ApplicationController < ActionController::Base

  if Rails.env.staging? || Rails.env.production?
    http_basic_authenticate_with name: 'signal', password: 'MeagherMacRedmond'
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  helper_method :current_user_session, :current_user

  Time::DATE_FORMATS[:simple] = I18n.t('controllers.application.date_formats.simple')
  Time::DATE_FORMATS[:standard] = I18n.t('controllers.application.date_formats.standard')

  def self.generate_random_code(number_of_characters=20)
    possible_characters = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    the_answer = ''
    possible_character_size = possible_characters.size
    number_of_characters.times do
      the_answer << possible_characters[rand(possible_character_size)]
    end
    the_answer
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def logged_in_required
    unless current_user
      flash[:error] = I18n.t('controllers.application.logged_in_required.flash_error')
      redirect_to sign_in_url
      false
    end
  end

  def logged_out_required
    if current_user
      flash[:error] = I18n.t('controllers.application.logged_out_required.flash_error')
      redirect_to root_url
      false
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    if session[:return_to]
      destination = session[:return_to]
      session[:return_to] = nil
    else
      destination = default
      session[:return_to] = nil
    end
    redirect_to(destination)
  end


  def ensure_user_is_of_type(authorised_features)
    logged_in_required
    the_user_group = current_user.user_group
    # for a list of permitted features, see UserGroup::FEATURES

    permission_granted = false

    authorised_features.each do |permitted_thing|
      if (the_user_group.individual_student && permitted_thing == 'individual_student') ||
         (the_user_group.corporate_student  && permitted_thing == 'corporate_student') ||
         (the_user_group.tutor              && permitted_thing == 'tutor') ||
         (the_user_group.blogger            && permitted_thing == 'blogger') ||
         (the_user_group.corporate_customer && permitted_thing == 'corporate_customer') ||
         (the_user_group.content_manager    && permitted_thing == 'content_manager') ||
         (the_user_group.forum_manager      && permitted_thing == 'forum_manager') ||
         (the_user_group.site_admin)

        permission_granted = true
      end
    end

    unless permission_granted
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to root_url
      false
    end
  end
  helper_method :ensure_user_is_of_type

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { locale: I18n.locale }
  end

end
