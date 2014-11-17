# == Schema Information
#
# Table name: forum_topics
#
#  id                       :integer          not null, primary key
#  forum_topic_id           :integer
#  course_module_element_id :integer
#  heading                  :string(255)
#  description              :text
#  active                   :boolean          default(TRUE), not null
#  publish_from             :datetime
#  publish_until            :datetime
#  reviewed_by              :integer
#  created_at               :datetime
#  updated_at               :datetime
#

require 'rails_helper'

describe ForumTopic do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ForumTopic.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(ForumTopic.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:forum_topic) }
  it { should belong_to(:course_module_element) }
  it { should belong_to(:parent) }
  xit { should belong_to(:reviewer) }
  it { should have_many(:forum_posts) }

  # validation
  it { should validate_presence_of(:forum_topic_id) }
  it { should validate_numericality_of(:forum_topic_id) }

  it { should validate_presence_of(:course_module_element_id) }
  it { should validate_numericality_of(:course_module_element_id) }

  it { should validate_presence_of(:heading) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:publish_from) }

  it { should validate_presence_of(:publish_until) }

  it { should validate_presence_of(:reviewed_by) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ForumTopic).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
