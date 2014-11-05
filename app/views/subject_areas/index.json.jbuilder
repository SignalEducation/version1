json.array!(@subject_areas) do |subject_area|
  json.extract! subject_area, :id, :name, :name_url, :sorting_order, :active
  json.url subject_area_url(subject_area, format: :json)
end
