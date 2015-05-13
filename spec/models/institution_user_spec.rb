# == Schema Information
#
# Table name: institution_users
#
#  id                          :integer          not null, primary key
#  institution_id              :integer
#  user_id                     :integer
#  student_registration_number :string(255)
#  student                     :boolean          default(FALSE), not null
#  qualified                   :boolean          default(FALSE), not null
#  created_at                  :datetime
#  updated_at                  :datetime
#  exam_number                 :string(255)
#  membership_number           :string(255)
#

require 'rails_helper'

describe InstitutionUser do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  InstitutionUser.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()InstitutionUser.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:institution) }
  it { should belong_to(:user) }

  # validation
  it { should validate_presence_of(:institution_id) }
  it { should validate_numericality_of(:institution_id) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_length_of(:student_registration_number).is_at_most(255) }
  it { should validate_length_of(:membership_number).is_at_most(255) }
  it { should validate_length_of(:exam_number).is_at_most(255) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(InstitutionUser).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
