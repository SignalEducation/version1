json.array!(@exam_levels) do |exam_level|
  json.extract! exam_level, :id, :name, :short_name, :name_url, :description, :feedback_url, :help_desk_url, :subject_area_id, :sorting_order, :active
  json.url exam_level_url(exam_level, format: :json)
end
