json.array!(@exam_bodies) do |exam_body|
  json.extract! exam_body, :id, :name, :url
  json.url exam_body_url(exam_body, format: :json)
end
