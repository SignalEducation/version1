# == Schema Information
#
# Table name: content_page_sections
#
#  id                :integer          not null, primary key
#  content_page_id   :integer
#  text_content      :text
#  panel_colour      :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  subject_course_id :integer
#  sorting_order     :integer
#

require 'rails_helper'

describe ContentPageSection do

  # relationships
  it { should belong_to(:content_page) }

  # validation
  it { should validate_presence_of(:content_page_id) }
  it { should validate_numericality_of(:content_page_id) }

  it { should validate_presence_of(:text_content) }

  it { should validate_presence_of(:panel_colour) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ContentPageSection).to respond_to(:all_in_order) }

  # class methods
  #it { expect(ContentPageSection).to respond_to(:method_name) }

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
