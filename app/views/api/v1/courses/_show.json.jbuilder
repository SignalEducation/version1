json.course do
  json.id             course.id
  json.name           course.name
  json.name_url       course.name_url
  json.sorting_order  course.sorting_order
  json.description    course.description
  json.release_date   course.release_date
  json.level_id       course.level_id
  json.key_area_id    course.key_area_id
  json.key_area       course&.key_area&.name
  json.category_label course.category_label
  json.icon_label     course.icon_label
  json.unit_label     course.unit_hour_label

  json.sections do
    if course.course_sections.present?
      json.array! course.course_sections.includes(:course_lessons).all_active.all_in_order.each do |section|
        json.id   section.id
        json.name section.name
        json.url  section.name_url

        json.lessons do
          if section.course_lessons.present?
            json.array! section.course_lessons.includes(:course_steps).all_active.all_in_order.each do |lesson|
              json.id          lesson.id
              json.name        lesson.name
              json.url         lesson.name_url
              json.description lesson.description
              json.free        lesson.free

              json.steps do
                if lesson.course_steps.present?
                  json.array! lesson.course_steps.includes(:course_video).all_active.all_in_order.each do |step|
                    json.id   step.id
                    json.name step.name
                    json.url  step.name_url
                    json.kind step.type_name
                    json.link show_course_url(step.course_lesson.course_section.course.name_url,
                                              step.course_lesson.course_section.name_url,
                                              step.course_lesson.name_url,
                                              step.name_url)

                    json.video_data do
                      if step.is_video
                        json.vimeo_guid step.course_video.vimeo_guid
                        json.dacast_id  step.course_video.dacast_id
                        json.duration   step.course_video.duration
                      else
                        json.nil!
                      end
                    end
                  end
                else
                  json.nil!
                end
              end
            end
          else
            json.nil!
          end
        end
      end
    else
      json.nil!
    end
  end
end
