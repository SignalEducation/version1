json.groups do
  json.array! @groups do |group|
    json.id                group.id
    json.name              group.name
    json.name_url          group.name_url
    json.description       group.description
    json.short_description group.short_description

    json.key_areas do
      json.array! group.key_areas.includes(:courses).all_active.all_in_order do |key_area|
        json.id       key_area.id
        json.name     key_area.name
        json.group_id key_area.group_id

        json.courses do
          if key_area.courses.present?
            json.array! key_area.courses do |course|
              json.id             course.id
              json.name           course.name
              json.name_url       course.name_url
              json.level_id       course.level_id
            end
          else
            json.nil!
          end
        end
      end
    end

    json.levels do
      json.array! group.levels.all_active.all_in_order do |level|
        json.id       level.id
        json.name     level.name
        json.name_url level.name_url
        json.track    level.track
        json.sub_text level.sub_text

        json.courses do
          json.array! level.courses.includes(:exam_body, :key_area).all_active.all_in_order.each do |course|
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

            json.exam_body do
              json.id   course.exam_body.id
              json.name course.exam_body.name
              json.url  course.exam_body.url
            end
          end
        end
      end
    end
  end
end
