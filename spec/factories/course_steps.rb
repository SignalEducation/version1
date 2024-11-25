# == Schema Information
#
# Table name: course_steps
#
#  id                        :integer          not null, primary key
#  name                      :string(255)
#  name_url                  :string(255)
#  description               :text
#  estimated_time_in_seconds :integer
#  course_lesson_id          :integer
#  sorting_order             :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default("false"), not null
#  is_quiz                   :boolean          default("false"), not null
#  active                    :boolean          default("true"), not null
#  destroyed_at              :datetime
#  seo_description           :string
#  seo_no_index              :boolean          default("false")
#  number_of_questions       :integer          default("0")
#  duration                  :float            default("0.0")
#  temporary_label           :string
#  is_constructed_response   :boolean          default("false"), not null
#  available_on_trial        :boolean          default("false")
#  related_course_step_id    :integer
#  is_note                   :boolean          default("false")
#  vid_end_seconds           :integer
#  is_practice_question      :boolean
#

FactoryBot.define do
  factory :course_step do
    sequence(:name)             { |n| "Course Step #{n}" }
    sequence(:name_url)         { |n| "course-step-#{n}" }
    description                 { 'Lorem ipsum' }
    estimated_time_in_seconds   { 1 }
    vid_end_seconds             { 1 }
    course_lesson
    sorting_order               { 1 }
    active                      { true }
    seo_description             { 'Lorem Ipsum' }
    seo_no_index                { false }
    is_constructed_response     { false }

    trait :video_step do
      is_video { true }
      is_quiz  { false }
      is_note  { false }
    end

    trait :quiz_step do
      is_quiz  { true }
      is_video { false }
      is_note  { false }
    end

    trait :notes_step do
      is_quiz  { false }
      is_video { false }
      is_note  { true }
    end

    trait :practice_question_step do
      is_quiz               { false }
      is_video              { false }
      is_note               { false }
      is_practice_question  { true }
    end

    trait :constructed_response_step do
      is_quiz                 { false }
      is_video                { false }
      is_note                 { false }
      is_constructed_response { true }
    end

    trait :vimeo do
      association :course_video, :vimeo
    end

    trait :dacast do
      association :course_video, :dacast
    end
  end
end
