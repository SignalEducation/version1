# == Schema Information
#
# Table name: student_user_types
#
#  id            :integer          not null, primary key
#  name          :string
#  description   :text
#  subscription  :boolean          default(FALSE)
#  product_order :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  free_trial    :boolean          default(FALSE)
#

require 'rails_helper'

describe StudentUserType do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  StudentUserType.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(StudentUserType.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:description) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(StudentUserType).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
