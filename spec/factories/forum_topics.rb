# == Schema Information
#
# Table name: forum_topics
#
#  id                       :integer          not null, primary key
#  forum_topic_id           :integer
#  course_module_element_id :integer
#  heading                  :string
#  description              :text
#  active                   :boolean          default(TRUE), not null
#  publish_from             :datetime
#  publish_until            :datetime
#  reviewed_by              :integer
#  created_at               :datetime
#  updated_at               :datetime
#  created_by               :integer
#

FactoryGirl.define do
  factory :forum_topic do
    forum_topic_id 1
    course_module_element_id 1
    heading 'MyString'
    description 'MyText'
    active false
    publish_from { Time.now }
    publish_until { Time.now + 2.day }
    created_by 1
    reviewed_by nil
  end

end
