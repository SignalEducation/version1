# == Schema Information
#
# Table name: subject_course_categories
#
#  id           :integer          not null, primary key
#  name         :string
#  payment_type :string
#  active       :boolean          default(FALSE)
#  subdomain    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

describe SubjectCourseCategory do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  SubjectCourseCategory.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(SubjectCourseCategory.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:payment_type) }

  it { should validate_presence_of(:subdomain) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SubjectCourseCategory).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
