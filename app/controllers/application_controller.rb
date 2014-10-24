class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale

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

  def logged_in_required
    unless current_user
      flash[:error] = I18n.t('controllers.application.logged_in_required.flash_error')
      redirect_to root_url
      false
    end
  end

  def ensure_user_is_of_type(array_of_permitted_features)
    # stuff
  end
  helper_method :ensure_user_is_of_type

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { locale: I18n.locale }
  end

  def current_user
    false
  end

end
