# frozen_string_literal: true

puts '* Exam body'

ExamBody.where(id: 1).first_or_create!(
  name: 'ACCA',
  url: 'http://www.acca.ie',
  active: true,
  has_sittings: true
); print '.'

ExamBody.where(id: 2).first_or_create!(
  name: 'CPD',
  url: 'http://www.learnsignal.com',
  active: true,
  has_sittings: true,
  preferred_payment_frequency: 12
); print '.'

ExamBody.where(id: 3).first_or_create!(
  name: 'CIMA',
  url: 'https://www.cimaglobal.com/',
  active: false,
  has_sittings: true,
  preferred_payment_frequency: 3
); print '.'
