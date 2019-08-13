# frozen_string_literal: true

puts '* Exam body'

ExamBody.where(id: 1).first_or_create!(
  name: 'ACCA',
  url: 'http://www.acca.ie',
  landing_page_h1: 'ACCA H1',
  landing_page_paragraph: 'ACCA  P',
  active: true,
  has_sittings: true
); print '.'

ExamBody.where(id: 2).first_or_create!(
  name: 'CPD',
  url: 'http://www.learnsignal.com',
  landing_page_h1: 'CPD H1',
  landing_page_paragraph: 'CPD  P',
  active: true,
  has_sittings: true,
  preferred_payment_frequency: 12
); print '.'

ExamBody.where(id: 3).first_or_create!(
  name: 'CIMA',
  url: 'https://www.cimaglobal.com/',
  landing_page_h1: 'CIMA H1',
  landing_page_paragraph: 'CIMA  P', 
  active: false,
  has_sittings: true,
  preferred_payment_frequency: 3
); print '.'
