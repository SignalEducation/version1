# == Schema Information
#
# Table name: user_exam_levels
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  exam_level_id    :integer
#  exam_schedule_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

require 'rails_helper'

describe UserExamLevel do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  UserExamLevel.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(UserExamLevel.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:exam_level) }
  it { should belong_to(:exam_schedule) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:exam_level_id) }
  it { should validate_numericality_of(:exam_level_id) }

  it { should validate_presence_of(:exam_schedule_id) }
  it { should validate_numericality_of(:exam_schedule_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(UserExamLevel).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
