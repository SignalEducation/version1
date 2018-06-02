# == Schema Information
#
# Table name: scenario_questions
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  constructed_response_id  :integer
#  scenario_id              :integer
#  sorting_order            :integer
#  text_content             :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require 'rails_helper'

describe ScenarioQuestion do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ScenarioQuestion.column_names.each do |column_name|
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
  it { should belong_to(:scenario) }

  # validation
  it { should validate_presence_of(:course_module_element_id) }
  it { should validate_numericality_of(:course_module_element_id) }

  it { should validate_presence_of(:constructed_response_id) }
  it { should validate_numericality_of(:constructed_response_id) }

  it { should validate_presence_of(:scenario_id) }
  it { should validate_numericality_of(:scenario_id) }

  it { should validate_presence_of(:sorting_order) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ScenarioQuestion).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
