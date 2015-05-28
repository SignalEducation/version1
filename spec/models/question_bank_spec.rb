# == Schema Information
#
# Table name: question_banks
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  exam_level_id       :integer
#  number_of_questions :integer
#  easy_questions      :boolean          default(FALSE), not null
#  medium_questions    :boolean          default(FALSE), not null
#  hard_questions      :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'rails_helper'

describe QuestionBank do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  QuestionBank.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(QuestionBank.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:exam_level) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:exam_level_id) }
  it { should validate_numericality_of(:exam_level_id) }

  it { should validate_presence_of(:number_of_questions) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(QuestionBank).to respond_to(:all_in_order) }
  it { expect(QuestionBank).to respond_to(:all_easy) }
  it { expect(QuestionBank).to respond_to(:all_medium) }
  it { expect(QuestionBank).to respond_to(:all_hard) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
