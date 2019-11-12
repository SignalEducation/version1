# frozen_string_literal: true

json.id            resource.id
json.name          resource.name
json.sorting_order resource.sorting_order
json.file do
  json.name resource.document_file_name
  json.url  resource.document.url(:original, timestamp: false)
end
