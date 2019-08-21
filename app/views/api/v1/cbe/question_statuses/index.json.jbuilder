json.array! @question_statuses do |question_status|
  json.call(question_status, :id, :name)
end
