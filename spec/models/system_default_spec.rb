# == Schema Information
#
# Table name: system_defaults
#
#  id                               :integer          not null, primary key
#  individual_student_user_group_id :integer
#  corporate_student_user_group_id  :integer
#  corporate_customer_user_group_id :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#

require 'rails_helper'

describe SystemDefault do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  SystemDefault.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(SystemDefault.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  xit { should belong_to(:individual_student_user_group) }
  xit { should belong_to(:corporate_student_user_group) }
  xit { should belong_to(:corporate_customer_user_group) }

  # validation
  it { should validate_presence_of(:individual_student_user_group_id) }
  it { should validate_numericality_of(:individual_student_user_group_id) }

  it { should validate_presence_of(:corporate_student_user_group_id) }
  it { should validate_numericality_of(:corporate_student_user_group_id) }

  it { should validate_presence_of(:corporate_customer_user_group_id) }
  it { should validate_numericality_of(:corporate_customer_user_group_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SystemDefault).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
