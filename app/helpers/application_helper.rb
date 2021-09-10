module ApplicationHelper
  def tick_or_cross(the_thing)
    color = the_thing ? '#21CE99' : '#eb4242'
    the_class = the_thing ? 'glyphicon glyphicon-ok' : 'glyphicon glyphicon-remove'
    html_sanitizer('', the_class, "color: #{color};")
  end

  def red_or_green_arrow(the_thing)
    color = the_thing ? '#21CE99' : '#eb4242'
    html_sanitizer('', 'glyphicon glyphicon-arrow-right', "color: #{color};")
  end

  def red_or_green_text(the_thing, letter)
    color = the_thing ? '#21CE99' : '#eb4242'
    html_sanitizer(letter, '', "color: #{color};")
  end

  def red_or_green_tick(the_thing)
    the_thing ? 'check' : 'close'
  end

  def sidepanel_border_radius(course_step_index, loop_index, loop_length)
    classes = ['']
    classes = ['active-step'] if course_step_index - 1 == loop_index
    classes << 'step-first-step' if loop_index.zero?
    classes << 'step-last-step' if loop_index == loop_length - 1
    classes
  end

  def app_eval_controller_action(controller_name, action_name)
    classes = ['']
    classes = ['page-light'] if controller_name == 'student_sign_ups' && action_name != 'new'
    classes << 'page-gray' if controller_name == 'courses' || action_name == 'account_verified'
    classes
  end

  def alt_video_player(video_player)
    'dacast-player' if video_player == 'dacast'
  end

  def flagged_for_review(the_thing)
    color = the_thing ? '#eb4242' : '#ffffff'
    the_class = 'glyphicon glyphicon-flag'
    html_sanitizer('', the_class, "color: #{color};")
  end

  def number_in_local_currency(amount, currency)
    number_to_currency(amount, unit: currency.leading_symbol, separator: I18n.t('views.general.numbers.decimal_separator'), delimiter: I18n.t('views.general.numbers.thousands_separator'), precision: 2)
  end

  def number_in_local_currency_no_precision(amount, currency)
    number_to_currency(amount, unit: currency.leading_symbol, separator: I18n.t('views.general.numbers.decimal_separator'), delimiter: I18n.t('views.general.numbers.thousands_separator'), precision: 0)
  end

  def sanitizer(some_text)
    sanitize(some_text.to_s.gsub("\r",'<br />'), tags: %w(p strong em br hr table caption tbody thead tfoot tr th td b i u ol ul li), attributes: %w(id class) )
  end

  def head_sanitizer(some_text)
    sanitize(some_text, tags: %w(meta script title style link), attributes: %w(name content type href src charset media rel) )
  end

  def body_sanitizer(some_text)
    raw(some_text)
  end

  def html_sanitizer(content, myclasses, mystyle)
    content_tag(:span, content, class: myclasses, style: mystyle)
  end

  def image_optimizer(img)
    image_reg = %r{[/.](gif|jpg|jpeg|tiff|png)}
    opt_img = img.split(image_reg)[0] + '-mob.' + img.split(image_reg)[1]

    return image_url(img) if verify_user_device == 'desktop' || !asset_exists?(opt_img)

    image_url(opt_img)
  end

  def verify_user_device
    return 'tablet' if request.user_agent&.match?(/(tablet|ipad)|(android(?!.*mobile))/i)
    return 'mobile' if request.user_agent&.match?(/Mobile|mobile/)

    'desktop'
  end

  def asset_exists?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? path
    elsif Rails.env.production? || Rails.env.staging?
      Rails.application.assets_manifest.assets[path].present?
    else
      (Rails.application.assets.find_asset path).present?
    end
  end

  def seconds_to_time(seconds)
    if seconds > 3600
      Time.at(seconds).utc.strftime('%H:%M:%S')
    else
      Time.at(seconds).utc.strftime('%M:%S')
    end
  end

  def humanize_time(seconds)
    # Used in the library UI
    if seconds > 3600
      Time.at(seconds).utc.strftime('%Hh %Mm')
    else
      Time.at(seconds).utc.strftime('%Mm %Ss')
    end
  end

  def simple_hour_time(seconds)
    if seconds > 3600
      (seconds / 3600).to_s + 'h'
    else
      (seconds / 60).to_s + 'm'
    end
  end

  def simple_time(seconds)
    # Used in the library UI
    if seconds > 3600
      Time.at(seconds).utc.strftime('%Hh')
    else
      Time.at(seconds).utc.strftime('%Mm')
    end
  end

  def humanize_datetime(date)
    # Used in the library UI
    date.utc.strftime('%d %b %y')
  end

  def humanize_datetime_full(date)
    # Used in the Account UI
    date.utc.strftime('%d %B %Y')
  end

  def timer_datetime(date)
    # Used for upgrade page timer
    date.utc.strftime('%Y/%m/%d %H:%M:%S')
  end

  def humanize_date_and_month(date)
    # Used in the library UI
    date.nil? ? '-' : date.utc.strftime('%d %b')
  end

  def humanize_date(date)
    # Used in the library UI
    date.nil? ? '-' : date.strftime('%d %b %y')
  end

  def humanize_stripe_date(date = 1.month.from_now)
    # Used in the library UI
    date.nil? ? '-' : date.strftime('%d %b %y')
  end

  def humanize_stripe_date_full(date = 1.month.from_now)
    # Used in the library UI
    date.nil? ? '-' : date.strftime('%d %B %Y')
  end

  def exam_sitting_date(date)
    # Used in the library UI
    date.strftime('%B %Y')
  end

  def referral_code_sharing_url(referral_code)
    "#{refer_a_friend_url}/?ref_code=#{referral_code.code}"
  end

  def plan_interval(interval)
    case interval
    when 1
      'paym'
    when 3
      'payq'
    else
      'paya'
    end
  end

  def plan_interval_alt(interval)
    case interval
    when 1
      'plan-monthly l-margin-top-big'
    when 3
      'plan-quarterly l-margin-top-big'
    when 12
      'plan-yearly l-margin-top-big'
    end
  end

  def sub_interval_alt(interval)
    case interval
    when 1
      'sub-monthly l-margin-top-big'
    when 3
      'sub-quarterly l-margin-top-big'
    when 12
      'sub-yearly l-margin-top-big'
    end
  end

  def sub_interval_color(interval)
    case interval
    when 1
      'monthly-color'
    when 3
      'quarterly-color'
    when 12
      'yearly-color'
    end
  end

  def sub_interval_btn_color(interval)
    case interval
    when 1
      'btn btn-cyan'
    when 3
      'btn btn-red'
    when 12
      'btn btn-purple'
    end
  end

  def navbar_landing_page_menu(landing_page)
    content_tag :li, class: 'nav-item' do
      onclick = ga_on_click_actions(landing_page.public_url)

      link_to footer_landing_page_url(landing_page.public_url), class: 'nav-link', onclick: onclick do
        content_tag('span', landing_page.name)
      end
    end
  end

  def verify_email_message(remain_days)
    if remain_days.positive?
      "Please verify your email within #{remain_days} days to continue free tier subscription."
    else
      'Please verify your email to continue free tier subscription.'
    end
  end

  def show_user_verified_restriction
    return unless current_user.show_verify_email_message?

    render partial: 'library/verification_restriction_modal'
  end
  private

  def ga_on_click_actions(public_url)
    case public_url
    when 'about-us'
      "gtag('event', 'clicks_header_about_us', {'event_category': 'pre-registration', 'event_label': 'about_us'})"
    when 'resources'
      "gtag('event', 'clicks_header_resources', {'event_category': 'pre-registration', 'event_label': 'resources'})"
    when 'testimonials'
      "gtag('event', 'clicks_header_testimonials', {'event_category': 'pre-registration', 'event_label': 'testimonials'})"
    when 'pricing'
      "gtag('event', 'clicks_header_pricing', {'event_category': 'pre-registration', 'event_label': 'pricing'})"
    else
      ''
    end
  end
end
