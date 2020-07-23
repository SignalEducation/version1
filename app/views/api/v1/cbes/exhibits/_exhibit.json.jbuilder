# frozen_string_literal: true

json.id            exhibit.id
json.scenario_id   exhibit.cbe_scenario_id
json.name          exhibit.name
json.kind          exhibit.kind
json.content       exhibit.content
json.sorting_order exhibit.sorting_order

json.document do
  if exhibit.pdf?
    json.name exhibit.document_file_name
    json.url  exhibit.document.url(:original, timestamp: false)
  else
    json.nil!
  end
end
