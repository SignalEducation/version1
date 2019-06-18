# frozen_string_literal: true

UserGroup.where(id: 1).first_or_create!(
  name: 'Individual students', description: 'Self-funded students',
  student_user: true, trial_or_sub_required: true
); print '.'

UserGroup.where(id: 2).first_or_create!(
  name: 'Content Management Team',
  description: 'Can manage course content',
  content_management_access: true, user_management_access: true,
  exercise_corrections_access: true
); print '.'

UserGroup.where(id: 3).first_or_create!(
  name: 'Customer Support Team',
  description: 'Can manage users and their accounts',
  user_management_access: true, exercise_corrections_access: true
); print '.'

UserGroup.where(id: 4).first_or_create!(
  name: 'Marketing Team',
  description: 'Can manage users and their accounts',
  system_requirements_access: true, stripe_management_access: true,
  user_management_access: true, marketing_resources_access: true
); print '.'

UserGroup.where(id: 5).first_or_create!(
  name: 'Admin', description: 'Can do everything',
  system_requirements_access: true, content_management_access: true,
  stripe_management_access: true, user_management_access: true,
  developer_access: true, marketing_resources_access: true,
  exercise_corrections_access: true, user_group_management_access: true
); print '.'

UserGroup.where(id: 6).first_or_create!(
  name: 'Complimentary users', description: 'Like a student, but free',
  student_user: true, trial_or_sub_required: false
); print '.'
