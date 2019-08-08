# == Schema Information
#
# Table name: subject_course_resources
#
#  id                       :integer          not null, primary key
#  name                     :string
#  subject_course_id        :integer
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_upload_file_name    :string
#  file_upload_content_type :string
#  file_upload_file_size    :bigint(8)
#  file_upload_updated_at   :datetime
#  external_url             :string
#  active                   :boolean          default(FALSE)
#  sorting_order            :integer
#  available_on_trial       :boolean          default(FALSE)
#

require 'rails_helper'

describe SubjectCourseResource do

  # relationships
  it { should belong_to(:subject_course) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:subject_course_id) }
  it { should validate_numericality_of(:subject_course_id) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SubjectCourseResource).to respond_to(:all_in_order) }
  it { expect(SubjectCourseResource).to respond_to(:all_active) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
