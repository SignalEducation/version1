# == Schema Information
#
# Table name: exam_body_user_details
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  exam_body_id   :integer
#  student_number :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

describe ExamBodyUserDetail do

  # Constants
  #it { expect(ExamBodyUserDetail.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:exam_body) }

  # validation
  it { should validate_presence_of(:user_id) }

  it { should validate_presence_of(:exam_body_id) }

  it { should validate_presence_of(:student_number) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ExamBodyUserDetail).to respond_to(:all_in_order) }

  # class methods
  #it { expect(ExamBodyUserDetail).to respond_to(:method_name) }

  # instance methods
  it { should respond_to(:destroyable?) }

end
