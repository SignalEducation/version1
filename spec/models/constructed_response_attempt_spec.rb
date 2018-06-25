# == Schema Information
#
# Table name: constructed_response_attempts
#
#  id                                :integer          not null, primary key
#  constructed_response_id           :integer
#  scenario_id                       :integer
#  course_module_element_id          :integer
#  course_module_element_user_log_id :integer
#  user_id                           :integer
#  original_scenario_text_content    :text
#  user_edited_scenario_text_content :text
#  status                            :string
#  flagged_for_review                :boolean          default(FALSE)
#  time_in_seconds                   :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#

require 'rails_helper'

describe ConstructedResponseAttempt do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ConstructedResponseAttempt.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(ConstructedResponseAttempt.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:constructed_response) }
  it { should belong_to(:scenario) }
  it { should belong_to(:course_module_element) }
  it { should belong_to(:course_module_element_user_log) }
  it { should belong_to(:user) }

  # validation
  it { should validate_presence_of(:constructed_response_id) }
  it { should validate_numericality_of(:constructed_response_id) }

  it { should validate_presence_of(:scenario_id) }
  it { should validate_numericality_of(:scenario_id) }

  it { should validate_presence_of(:course_module_element_id) }
  it { should validate_numericality_of(:course_module_element_id) }

  it { should validate_presence_of(:course_module_element_user_log_id) }
  it { should validate_numericality_of(:course_module_element_user_log_id) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:original_scenario_text_content) }

  it { should validate_presence_of(:user_edited_scenario_text_content) }

  it { should validate_presence_of(:status) }

  it { should validate_presence_of(:time_in_seconds) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ConstructedResponseAttempt).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
