# == Schema Information
#
# Table name: exam_bodies
#
#  id         :integer          not null, primary key
#  name       :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe ExamBody do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ExamBody.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  xit { should have_many(:enrollments) }
  xit { should have_many(:subject_courses) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:url) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ExamBody).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
