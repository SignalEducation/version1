# frozen_string_literal: true

json.array! @resources do |resource|
  json.partial! 'resource', locals: { resource: resource }
end
