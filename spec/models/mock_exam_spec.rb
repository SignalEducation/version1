# == Schema Information
#
# Table name: mock_exams
#
#  id                       :integer          not null, primary key
#  course_id        :integer
#  name                     :string
#  sorting_order            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_file_name           :string
#  file_content_type        :string
#  file_file_size           :integer
#  file_updated_at          :datetime
#  cover_image_file_name    :string
#  cover_image_content_type :string
#  cover_image_file_size    :integer
#  cover_image_updated_at   :datetime
#

require 'rails_helper'

describe MockExam do
  # relationships
  it { should belong_to(:course) }
  it { should have_many(:products) }
  it { should have_many(:orders) }

  # validation
  it 'is valid without a course' do
    expect(build_stubbed(:mock_exam, course: nil)).to be_valid
  end

  it { should validate_presence_of(:name) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(MockExam).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
