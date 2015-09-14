# == Schema Information
#
# Table name: subject_courses
#
#  id                :integer          not null, primary key
#  name              :string
#  name_url          :string
#  sorting_order     :integer
#  active            :boolean          default(FALSE), not null
#  live              :boolean          default(FALSE), not null
#  wistia_guid       :string
#  tutor_id          :integer
#  cme_count         :integer
#  video_count       :integer
#  quiz_count        :integer
#  question_count    :integer
#  description       :text
#  short_description :string
#  mailchimp_guid    :string
#  forum_url         :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :subject_course do
    name "MyString"
    name_url "MyString"
    sorting_order 1
    active false
    live false
    wistia_guid "MyString"
    tutor_id 1
    cme_count 1
    video_count 1
    quiz_count 1
    question_count 1
    description "MyText"
    short_description "MyString"
    mailchimp_guid "MyString"
    forum_url "MyString"
  end

end
