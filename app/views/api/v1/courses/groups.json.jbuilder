json.groups do
  json.array! @groups do |group|
    json.id                group.id
    json.name              group.name
    json.name_url          group.name_url
    json.description       group.description
    json.short_description group.short_description

    json.levels do
      json.array! group.levels.all_active.all_in_order do |level|
        json.id       level.id
        json.name     level.name
        json.name_url level.name_url

        json.courses do
          json.array! level.courses.all_active.all_in_order.each do |course|
            json.partial! 'show', locals: { course: course }

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
