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

  subject { FactoryBot.build(:white_paper) }

  # relationships
  it { should have_many(:white_paper_requests) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url) }

  it { should validate_presence_of(:description) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(WhitePaper).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
