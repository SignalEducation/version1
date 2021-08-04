# frozen_string_literal: true

json.array! @exam_bodies do |exam_body|
  json.partial! 'exam_body', locals: { exam_body: exam_body }
end
