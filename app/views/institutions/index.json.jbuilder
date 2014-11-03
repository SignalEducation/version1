json.array!(@institutions) do |institution|
  json.extract! institution, :id, :name, :short_name, :name_url, :description, :feedback_url, :help_desk_url, :subject_area_id, :sorting_order, :active
  json.url institution_url(institution, format: :json)
end
