# == Schema Information
#
# Table name: tutor_applications
#
#  id          :integer          not null, primary key
#  first_name  :string
#  last_name   :string
#  email       :string
#  info        :text
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

describe TutorApplication do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  TutorApplication.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(TutorApplication.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships

  # validation
  it { should validate_presence_of(:first_name) }
  it { should validate_length_of(:first_name).is_at_most(255)}

  it { should validate_presence_of(:last_name) }
  it { should validate_length_of(:last_name).is_at_most(255)}

  it { should validate_presence_of(:email) }
  it { should validate_length_of(:email).is_at_most(255)}

  it { should validate_presence_of(:info) }

  it { should validate_presence_of(:description) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(TutorApplication).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
