# == Schema Information
#
# Table name: course_resources
#
#  id                       :integer          not null, primary key
#  name                     :string
#  course_id        :integer
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_upload_file_name    :string
#  file_upload_content_type :string
#  file_upload_file_size    :integer
#  file_upload_updated_at   :datetime
#  external_url             :string
#  active                   :boolean          default("false")
#  sorting_order            :integer
#  available_on_trial       :boolean          default("false")
#

require 'rails_helper'

describe CourseResource do
  # relationships
  it { should belong_to(:course) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:course) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseResource).to respond_to(:all_in_order) }
  it { expect(CourseResource).to respond_to(:all_active) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
end
