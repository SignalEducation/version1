# == Schema Information
#
# Table name: course_sections
#
#  id                        :integer          not null, primary key
#  subject_course_id         :integer
#  name                      :string
#  name_url                  :string
#  sorting_order             :integer
#  active                    :boolean          default(FALSE)
#  counts_towards_completion :boolean          default(FALSE)
#  assumed_knowledge         :boolean          default(FALSE)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  cme_count                 :integer          default(0)
#  video_count               :integer          default(0)
#  quiz_count                :integer          default(0)
#  destroyed_at              :datetime
#

require 'rails_helper'

describe CourseSection do

  # Constants
  #it { expect(CourseSection.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:subject_course) }

  # validation
  it { should validate_presence_of(:subject_course_id) }
  it { should validate_numericality_of(:subject_course_id) }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:name_url) }

  it { should validate_presence_of(:sorting_order) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseSection).to respond_to(:all_in_order) }

  # class methods
  #it { expect(CourseSection).to respond_to(:method_name) }

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
