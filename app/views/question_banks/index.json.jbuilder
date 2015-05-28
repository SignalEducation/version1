json.array!(@question_banks) do |question_bank|
  json.extract! question_bank, :id, :user_id, :exam_level_id, :number_of_questions, :easy_questions, :medium_questions, :hard_questions
  json.url question_bank_url(question_bank, format: :json)
end
