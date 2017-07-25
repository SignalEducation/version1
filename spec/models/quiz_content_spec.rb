# == Schema Information
#
# Table name: quiz_contents
#
#  id                 :integer          not null, primary key
#  quiz_question_id   :integer
#  quiz_answer_id     :integer
#  text_content       :text
#  sorting_order      :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  quiz_solution_id   :integer
#  destroyed_at       :datetime
#

require 'rails_helper'

describe QuizContent do

  # attr-accessible
  black_list = %w(id created_at updated_at destroyed_at)
  QuizContent.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:quiz_answer) }
  it { should belong_to(:quiz_question) }
  it { should belong_to(:quiz_solution) }

  # validation
  # tests for custom-validator 'one_parent_only'
  context 'if both values set...' do
    before :each do
      allow(subject).to receive_messages(quiz_question_id: 1, quiz_answer_id: 1,
                                         text_content: 'ABC', sorting_order: 1)
      subject.save!
      subject.sorting_order = 2
      subject.valid?
    end

    it { expect(subject.errors[:base].try(:first)).to eq(I18n.t('models.quiz_content.can_t_assign_to_multiple_things')) }
  end

  context 'if neither value set...' do
    before :each do
      allow(subject).to receive_messages(quiz_question_id: nil, quiz_answer_id: nil,
                                         text_content: 'ABC', sorting_order: 1)
      subject.save!
      subject.sorting_order = 2
      subject.valid?
    end
    it { expect(subject.errors[:base].try(:first)).to eq(I18n.t('models.quiz_content.must_assign_to_at_least_one_thing')) }
  end

  it { should_not validate_presence_of(:quiz_question_id) }
  it { should_not validate_presence_of(:quiz_answer_id) }
  it { should_not validate_presence_of(:quiz_solution_id) }
  it { should validate_presence_of(:text_content) }
  it { should validate_presence_of(:sorting_order) }

  # callbacks
  it { should callback(:set_default_values).after(:initialize) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(QuizContent).to respond_to(:all_in_order) }
  it { expect(QuizContent).to respond_to(:all_destroyed) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
