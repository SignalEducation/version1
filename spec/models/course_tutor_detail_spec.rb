# == Schema Information
#
# Table name: course_tutor_details
#
#  id                :integer          not null, primary key
#  subject_course_id :integer
#  user_id           :integer
#  sorting_order     :integer
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

describe CourseTutorDetail do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  CourseTutorDetail.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(CourseTutorDetail.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:subject_course) }
  it { should belong_to(:user) }

  # validation
  it { should validate_presence_of(:subject_course_id) }
  it { should validate_numericality_of(:subject_course_id) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:title) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseTutorDetail).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
