json.array!(@tutor_applications) do |tutor_application|
  json.extract! tutor_application, :id, :first_name, :last_name, :email, :info, :description
  json.url tutor_application_url(tutor_application, format: :json)
end
