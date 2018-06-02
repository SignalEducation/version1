# == Schema Information
#
# Table name: scenarios
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  constructed_response_id  :integer
#  sorting_order            :integer
#  text_content             :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require 'rails_helper'

describe Scenario do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  Scenario.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:course_module_element) }
  it { should belong_to(:constructed_response) }

  # validation
  it { should validate_presence_of(:course_module_element_id) }
  it { should validate_numericality_of(:course_module_element_id) }

  it { should validate_presence_of(:constructed_response_id) }
  it { should validate_numericality_of(:constructed_response_id) }

  it { should validate_presence_of(:text_content) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Scenario).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
