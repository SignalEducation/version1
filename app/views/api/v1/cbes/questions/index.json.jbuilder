json.array! @questions do |question|
  json.partial! 'question', locals: { question: question }
end
