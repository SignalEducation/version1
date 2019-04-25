# frozen_string_literal: true

UserGroup.where(id: 1).first_or_create!(
  name: 'Individual students', description: 'Self-funded students'
); print '.'

UserGroup.where(id: 2).first_or_create!(
  name: 'Corporate Student',
  description: 'Student, funded by a corporate customer'
); print '.'

UserGroup.where(id: 3).first_or_create!(
  name: 'Corporate customers',
  description: 'Administrative users on behalf of a corporate customer'
); print '.'

UserGroup.where(id: 4).first_or_create!(
  name: 'Tutor', description: 'Can create course content'
); print '.'

UserGroup.where(id: 5).first_or_create!(
  name: 'Blogger', description: 'Can create blog content'
); print '.'

UserGroup.where(id: 6).first_or_create!(
  name: 'Content manager',
  description: 'Can manage forum, blog and static pages'
); print '.'

UserGroup.where(id: 7).first_or_create!(
  name: 'Admin', description: 'Can do everything'
); print '.'

UserGroup.where(id: 8).first_or_create!(
  name: 'Complimentary users', description: 'Like a student, but free'
); print '.'
