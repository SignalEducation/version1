# frozen_string_literal: true

json.key_areas do
  json.array! @key_areas do |key_area|
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
