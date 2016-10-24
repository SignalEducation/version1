# == Schema Information
#
# Table name: white_papers
#
#  id                       :integer          not null, primary key
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_file_name           :string
#  file_content_type        :string
#  file_file_size           :integer
#  file_updated_at          :datetime
#  sorting_order            :integer
#  cover_image_file_name    :string
#  cover_image_content_type :string
#  cover_image_file_size    :integer
#  cover_image_updated_at   :datetime
#  name_url                 :string
#  name                     :string
#  subject_course_id        :integer
#

require 'rails_helper'

describe WhitePaper do

  # attr-accessible
  black_list = %w(id created_at updated_at file_updated_at cover_image_file_size cover_image_file_name cover_image_updated_at file_file_size file_content_type cover_image_content_type file_file_name)
  WhitePaper.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # relationships
  it { should have_many(:white_paper_requests) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:name_url) }
  xit { should validate_uniqueness_of(:name_url) }

  it { should validate_presence_of(:description) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(WhitePaper).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
