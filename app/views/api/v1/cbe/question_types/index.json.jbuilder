json.array! @question_types do |question_type|
  json.call(question_type, :id, :name)
end
