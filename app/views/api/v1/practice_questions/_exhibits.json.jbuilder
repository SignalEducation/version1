json.exhibits practice_question.exhibits.order(:sorting_order) do |exhibit|
  json.id                   exhibit.id
  json.name                 exhibit.name
  json.sorting_order        exhibit.sorting_order
  json.kind                 exhibit.kind
  json.content              exhibit.content
  json.practice_question_id practice_question.id
  json.document do
    if exhibit.document.present?
        json.name exhibit.document_file_name
        json.url  exhibit.document.url(:original, timestamp: false)
    else
        json.nil!
    end
  end
end