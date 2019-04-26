# frozen_string_literal: true

puts '* Exam body'

ExamBody.where(id: 1).first_or_create!(
  name: 'ACCA',
  url: 'http://www.acca.ie',
  active: true
); print '.'
