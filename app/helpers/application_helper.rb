module ApplicationHelper

  def tick_or_cross(the_thing)
    the_thing ?
            "<span style='color: #21CE99;' class='glyphicon glyphicon-ok'></span>".html_safe :
            "<span style='color: #eb4242;' class='glyphicon glyphicon-remove'></span>".html_safe
  end

  def number_in_local_currency(amount, currency_id)
    ccy = Currency.find(currency_id)
    number_to_currency(amount, unit: ccy.leading_symbol, separator: I18n.t('views.general.numbers.decimal_separator'), delimiter: I18n.t('views.general.numbers.decimal_separator'), precision: 2)
  end

  def number_in_local_currency_no_precision(amount, currency_id)
    ccy = Currency.find(currency_id)
    number_to_currency(amount, unit: ccy.leading_symbol, separator: I18n.t('views.general.numbers.decimal_separator'), delimiter: I18n.t('views.general.numbers.decimal_separator'), precision: 0)
  end

  def sanitizer(some_text)
    sanitize(some_text.to_s.gsub("\r",'<br />'), tags: %w(p strong em br hr table caption tbody thead tfoot tr th td b i u ol ul li), attributes: %w(id class) )
  end

  def head_sanitizer(some_text)
    sanitize(some_text, tags: %w(meta script title style link), attributes: %w(name content type href src charset media rel) )
  end

  def body_sanitizer(some_text)
    raw(some_text)
    # sanitize(some_text, tags: %w(br hr table tbody thead tfoot tr th td b i u h1 h2 h3 h4 h5 h6 p div a img button span ul ol li nav header), attributes: %w(id class style href src url data-toggle data-target data-ride data-slide-to role aria-hidden aria-expanded aria-controls), css: %w(url) )
  end

  def seconds_to_time(seconds)
    if seconds > 3600
      Time.at(seconds).utc.strftime('%H:%M:%S')
    else
      Time.at(seconds).utc.strftime('%M:%S')
    end
  end

  def humanize_time(seconds)  # Used in the library UI
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

  def simple_time(seconds)  # Used in the library UI
    if seconds > 3600
      Time.at(seconds).utc.strftime('%Hh')
    else
      Time.at(seconds).utc.strftime('%Mm')
    end
  end

  def humanize_datetime(date)  # Used in the library UI
    date.utc.strftime('%d %b %y')
  end

  def humanize_date_and_month(date)  # Used in the library UI
    date.utc.strftime('%d %b')
  end

  def exam_sitting_date(date)  # Used in the library UI
    date.strftime("%B %Y")
  end

  def referral_code_sharing_url(referral_code)
    "#{library_url}/?ref_code=#{referral_code.code}"
  end

  def plan_interval(interval)
    if interval == 1
      "plan-monthly l-margin-top-big"
    elsif interval == 3
      "plan-quarterly blue-border"
    elsif interval == 12
      "plan-yearly l-margin-top-big"
    end
  end

  def plan_interval_alt(interval)
    if interval == 1
      "plan-monthly l-margin-top-big"
    elsif interval == 3
      "plan-quarterly l-margin-top-big"
    elsif interval == 12
      "plan-yearly l-margin-top-big"
    end
  end
end

class DanFormBuilder < ActionView::Helpers::FormBuilder

  # http://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html

  def collection_related_select(target_attribute, collection, collection_index,
                                collection_label, collection_trigger, parent_field,
                                options={}, html_options={})

    new_collection = collection.map {|x| [x[collection_index], x[collection_label], x[collection_trigger] ] }
    this_field_name = @object_name + '_' + target_attribute.to_s
    other_field_name = @object_name + '_' + parent_field.to_s
    @template.collection_select(@object_name, target_attribute, collection, collection_index, collection_label, options, html_options) + %(
    <script>
      if ($('script[src="/assets/related_select.js"]').length == 0) {
        jQuery.getScript('/assets/related_select.js');
      } // http://stackoverflow.com/questions/9521298/verify-external-script-is-loaded
      $(document).on('ready page:load', function() {
        watchChildSelect('#{this_field_name}', '#{other_field_name}', #{new_collection});
      })
    </script>
    ).html_safe
  end

end
