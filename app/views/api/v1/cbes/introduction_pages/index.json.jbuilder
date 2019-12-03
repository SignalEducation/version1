# frozen_string_literal: true

json.array! @pages do |page|
  json.partial! 'introduction_page', locals: { page: page }
end
