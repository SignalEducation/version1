# frozen_string_literal: true

Group.where(id: 1).first_or_create!(
  name: 'ACCA',
  seo_title: 'Test',
  seo_description: 'Test',
  short_description: 'Explore our ACCA Gold Approved courses offering high quality, affordable and flexible tuition designed to suit your needs.',
  description: 'Explore our ACCA Gold Approved courses offering high quality, affordable and flexible tuition designed to suit your needs.',
  name_url: 'acca',
  exam_body_id: 1,
  active: true
); print '.'

Group.where(id: 2).first_or_create!(
  name: 'CPD',
  seo_title: 'CPD',
  seo_description: 'CPD - Continuous Professional Development',
  short_description: 'Discover CPD courses designed by experts to help you maintain and develop the skills you need to be successful in your career.',
  description: 'Discover CPD courses designed by experts to help you maintain and develop the skills you need to be successful in your career.',
  name_url: 'cpd',
  exam_body_id: 2,
  active: true
); print '.'

Group.where(id: 3).first_or_create!(
  name: 'CIMA',
  seo_title: 'CIMA',
  seo_description: 'CIMA',
  short_description: 'CIMA',
  description: 'CIMA',
  name_url: 'cima',
  exam_body_id: 3,
  active: false
); print '.'
