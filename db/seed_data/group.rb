# frozen_string_literal: true

Group.where(id: 1).first_or_create!(
  name: 'ACCA',
  seo_title: 'Test',
  seo_description: 'Test',
  short_description: 'Test',
  description: 'Test',
  name_url: 'Test',
  exam_body_id: 1,
  active: true
); print '.'
