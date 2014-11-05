json.array!(@qualifications) do |qualification|
  json.extract! qualification, :id, :institution_id, :name, :name_url, :sorting_order, :active, :cpd_hours_required_per_year
  json.url qualification_url(qualification, format: :json)
end
