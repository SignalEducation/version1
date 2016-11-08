# == Schema Information
#
# Table name: mock_exams
#
#  id                       :integer          not null, primary key
#  subject_course_id        :integer
#  product_id               :integer
#  name                     :string
#  sorting_order            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_file_name           :string
#  file_content_type        :string
#  file_file_size           :integer
#  file_updated_at          :datetime
#  cover_image_file_name    :string
#  cover_image_content_type :string
#  cover_image_file_size    :integer
#  cover_image_updated_at   :datetime
#

require 'rails_helper'

describe MockExam do

  # attr-accessible
  black_list = %w(id created_at updated_at file_file_name file_content_type file_file_size file_updated_at cover_image_file_name cover_image_content_type cover_image_file_size cover_image_updated_at)
  MockExam.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:subject_course) }
  it { should belong_to(:product) }
  it { should have_many(:orders) }

  # validation
  it { should validate_presence_of(:subject_course_id) }
  it { should validate_numericality_of(:subject_course_id) }

  it { should validate_presence_of(:product_id) }
  it { should validate_numericality_of(:product_id) }

  it { should validate_presence_of(:name) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(MockExam).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
