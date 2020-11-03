module ApplicationHelper

  def tick_or_cross(the_thing)
    the_thing ?
            "<span style='color: #21CE99;' class='glyphicon glyphicon-ok'></span>".html_safe :
            "<span style='color: #eb4242;' class='glyphicon glyphicon-remove'></span>".html_safe
  end

  def flagged_for_review(the_thing)
    the_thing ?
            "<span style='color: #eb4242;' class='glyphicon glyphicon-flag'></span>".html_safe :
            "<span style='color: #ffffff;' class='glyphicon glyphicon-flag'></span>".html_safe
  end

  def number_in_local_currency(amount, currency)
    number_to_currency(amount, unit: currency.leading_symbol, separator: I18n.t('views.general.numbers.decimal_separator'), delimiter: I18n.t('views.general.numbers.decimal_separator'), precision: 2)
  end

  def number_in_local_currency_no_precision(amount, currency)
    number_to_currency(amount, unit: currency.leading_symbol, separator: I18n.t('views.general.numbers.decimal_separator'), delimiter: I18n.t('views.general.numbers.decimal_separator'), precision: 0)
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
      (seconds/3600).to_s + 'h'
    else
      (seconds/60).to_s + 'm'
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
end
