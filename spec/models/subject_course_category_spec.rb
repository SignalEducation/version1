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
  it { expect(SubjectCourseCategory.const_defined?(:PAYMENT_TYPES)).to eq(true) }

  # relationships
  it { should have_many(:subject_courses) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:payment_type) }

  it { should_not validate_presence_of(:subdomain) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SubjectCourseCategory).to respond_to(:all_in_order) }
  it { expect(SubjectCourseCategory).to respond_to(:all_active) }
  it { expect(SubjectCourseCategory).to respond_to(:all_product) }
  it { expect(SubjectCourseCategory).to respond_to(:all_subscription) }
  it { expect(SubjectCourseCategory).to respond_to(:all_corporate) }

  # class methods
  it { expect(SubjectCourseCategory).to respond_to(:default_subscription_category) }
  it { expect(SubjectCourseCategory).to respond_to(:default_product_category) }
  it { expect(SubjectCourseCategory).to respond_to(:default_corporate_category) }
  it { expect(SubjectCourseCategory).to respond_to(:default_subscription_category) }


  # instance methods
  it { should respond_to(:active_children) }
  it { should respond_to(:children) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:first_active_child) }



end
