module ApplicationHelper

  def tick_or_cross(the_thing)
    the_thing ?
            "<span style='color: green;' class='glyphicon glyphicon-ok'></span>".html_safe :
            "<span style='color: red;' class='glyphicon glyphicon-remove'></span>".html_safe
  end

  def completion_circle(hierarchy_thing)
    if hierarchy_thing.class == CourseModuleElement || hierarchy_thing.class == CourseModuleJumboQuiz
      percentage = hierarchy_thing.completed_by_user_or_guid(current_user.try(:id), current_session_guid) ? 100 : 0
    elsif [ExamLevel, ExamSection, CourseModule].include?(hierarchy_thing.class)
      percentage = hierarchy_thing.percentage_complete_by_user_or_guid(current_user.try(:id), current_session_guid)
    else
      percentage = nil
    end

    if percentage == 100
      "<span style='color: green;' class='glyphicon glyphicon-ok-sign'></span>".html_safe
    elsif percentage == 0
      "<span style='color: green; font-size: 107%;'>&#9711;</span>".html_safe
    elsif percentage.nil?
      #Do Nothing
    else
      "<span style='color: green; font-size: 122%;' title='#{percentage}%'>&#9680;</span>".html_safe
    end
  end

  def completion_label(hierarchy_thing)
    if hierarchy_thing.class == CourseModuleElement
      percentage = hierarchy_thing.completed_by_user_or_guid(current_user.try(:id), current_session_guid) ? 100 : 0
    elsif [ExamLevel, ExamSection, CourseModule].include?(hierarchy_thing.class)
      percentage = hierarchy_thing.percentage_complete_by_user_or_guid(current_user.try(:id), current_session_guid)
    else
      percentage = nil
    end

    if percentage == 100
      "<span style='background-color: green;' class='label label-default'>Done</span>".html_safe
    elsif percentage == 0
      if hierarchy_thing.first_active_cme
        "<a href='#{course_special_link(hierarchy_thing.first_active_cme)}'><span style='background-color: green;' class='label label-default'>Start</span></a>".html_safe
      end
    elsif percentage.nil?
      #Do Nothing
    else
      "<span style='background-color: #428BCA;' class='label label-default'>#{percentage}%</span>".html_safe
    end
  end

  def number_in_local_currency(amount, currency_id)
    ccy = Currency.find(currency_id)
    number_to_currency(amount, unit: ccy.leading_symbol, separator: I18n.t('views.general.numbers.decimal_separator'), delimiter: I18n.t('views.general.numbers.decimal_separator'), precision: 2)
  end

  def sanitizer(some_text)
    sanitize(some_text.to_s.gsub("\r",'<br />'), tags: %w(br hr table tbody thead tfoot tr th td b i u), attributes: %w(id class) )
  end

  def head_sanitizer(some_text)
    sanitize(some_text, tags: %w(meta script title style link), attributes: %w(name content type href src charset media rel) )
  end

  def body_sanitizer(some_text)
    raw(some_text)
    # sanitize(some_text, tags: %w(br hr table tbody thead tfoot tr th td b i u h1 h2 h3 h4 h5 h6 p div a img button span ul ol li nav header), attributes: %w(id class style href src url data-toggle data-target data-ride data-slide-to role aria-hidden aria-expanded aria-controls), css: %w(url) )
  end

  def breadcrumb_builder(the_thing)
    # This builds an array of objects starting at subject_area and ending at whatever the_thing is.
    if the_thing.parent
      breadcrumb_builder(the_thing.parent) + [the_thing]
    else
      [the_thing]
    end
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

