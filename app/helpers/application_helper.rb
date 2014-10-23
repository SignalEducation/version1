module ApplicationHelper

  def tick_or_cross(the_thing)
    the_thing ?
            "<span class='glyphicon glyphicon-ok'></span>".html_safe :
            "<span class='glyphicon glyphicon-remove'></span>".html_safe
  end

end
