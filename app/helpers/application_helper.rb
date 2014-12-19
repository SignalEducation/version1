module ApplicationHelper

  def tick_or_cross(the_thing)
    the_thing ?
            "<span class='glyphicon glyphicon-ok'></span>".html_safe :
            "<span class='glyphicon glyphicon-remove'></span>".html_safe
  end

  def number_in_local_currency(amount, currency_id)
    ccy = Currency.find(currency_id)
    number_to_currency(amount, unit: ccy.leading_symbol, separator: I18n.t('views.general.numbers.decimal_separator'), delimiter: I18n.t('views.general.numbers.decimal_separator'), precision: 2)
  end

  def sanitizer(some_text)
    sanitize(some_text.gsub("\r",'<br />'), tags: %w(br hr table tbody thead tfoot tr th td b i u h1 h2 h3 h4 h5 h6 p), attributes: %w(id class style) )
  end

  def seconds_to_time(seconds)
    Time.at(seconds).utc.strftime('%M:%S')
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

