class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale

  Time::DATE_FORMATS[:simple] = I18n.t('controllers.application.date_formats.simple')
  Time::DATE_FORMATS[:standard] = I18n.t('controllers.application.date_formats.standard')

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
