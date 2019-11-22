FactoryBot.define do
  factory :level do
    group_id                       { 1 }
    name                           { "MyString" }
    name_url                       { "MyString" }
    active                         { false }
    highlight_colour               { "MyString" }
    sorting_order                  { 1 }
    icon_label                     { 'MyString' }
    onboarding_course_heading      { 'Welcome Message' }
    onboarding_course_subheading   { 'Welcome Message' }
  end
end
