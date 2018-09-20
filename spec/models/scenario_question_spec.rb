# == Schema Information
#
# Table name: scenario_questions
#
#  id            :integer          not null, primary key
#  scenario_id   :integer
#  sorting_order :integer
#  text_content  :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  destroyed_at  :datetime
#

require 'rails_helper'

describe ScenarioQuestion do

  # attr-accessible
  black_list = %w(id created_at updated_at destroyed_at)
  ScenarioQuestion.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:scenario) }
  it { should have_many(:scenario_answer_templates) }
  it { should have_many(:scenario_question_attempts) }

  # validation
  it { should validate_presence_of(:scenario_id).on(:update) }
  it { should validate_numericality_of(:scenario_id).on(:update) }

  it { should validate_presence_of(:text_content) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ScenarioQuestion).to respond_to(:all_in_order) }

  # class methods
  it { expect(ScenarioQuestion).to respond_to(:question_nested_answer_template_is_blank?) }

  # instance methods
  it { should respond_to(:destroyable?) }


end
