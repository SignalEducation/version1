# == Schema Information
#
# Table name: scenario_answer_templates
#
#  id                   :integer          not null, primary key
#  scenario_question_id :integer
#  sorting_order        :integer
#  editor_type          :string
#  text_content         :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  destroyed_at         :datetime
#

require 'rails_helper'

describe ScenarioAnswerTemplate do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ScenarioAnswerTemplate.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(ScenarioAnswerTemplate.const_defined?(:FORMAT_TYPE)).to eq(true) }

  # relationships
  it { should belong_to(:course_module_element) }
  it { should belong_to(:constructed_response) }
  it { should belong_to(:scenario) }
  it { should belong_to(:scenario_question) }

  # validation
  it { should validate_presence_of(:course_module_element_id) }
  it { should validate_numericality_of(:course_module_element_id) }

  it { should validate_presence_of(:constructed_response_id) }
  it { should validate_numericality_of(:constructed_response_id) }

  it { should validate_presence_of(:scenario_id) }
  it { should validate_numericality_of(:scenario_id) }

  it { should validate_presence_of(:scenario_question_id) }
  it { should validate_numericality_of(:scenario_question_id) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:type) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ScenarioAnswerTemplate).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
