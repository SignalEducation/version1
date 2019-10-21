# frozen_string_literal: true

json.array! @cbes do |cbe|
  json.partial! 'cbe', locals: { cbe: cbe }
end
