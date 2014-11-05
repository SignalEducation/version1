json.array!(@exam_sections) do |exam_section|
  json.extract! exam_section, :id, :name, :name_url, :exam_level_id, :active, :sorting_order, :best_possible_first_attempt_score
  json.url exam_section_url(exam_section, format: :json)
end
