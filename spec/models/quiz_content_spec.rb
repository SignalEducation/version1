# == Schema Information
#
# Table name: quiz_contents
#
#  id                 :integer          not null, primary key
#  quiz_question_id   :integer
#  quiz_answer_id     :integer
#  text_content       :text
#  contains_mathjax   :boolean          not null
#  contains_image     :boolean          not null
#  sorting_order      :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#

require 'rails_helper'

describe QuizContent do

  # attr-accessible
  black_list = %w(id created_at updated_at contains_mathjax contains_image image_updated_at image_file_size image_file_name image_content_type)
  QuizContent.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(QuizContent.const_defined?(:CONTENT_TYPES)).to eq(true) }

  # relationships
  it { should belong_to(:quiz_question) }
  it { should belong_to(:quiz_answer) }

  # validation
  # tests for custom-validator 'question_or_answer_only'
  context 'if both values set...' do
    before :each do
      allow(subject).to receive_messages(quiz_question_id: 1,
                                         content_type: 'text',
                                         quiz_answer_id: 1, text_content: 'ABC', sorting_order: 1)
      subject.save!
      subject.sorting_order = 2
      subject.valid?
    end

    it { expect(subject.errors[:base].try(:first)).to eq(I18n.t('models.quiz_content.can_t_assign_to_question_and_answer')) }
  end

  context 'if neither value set...' do
    before :each do
      allow(subject).to receive_messages(quiz_question_id: nil,
                                         quiz_answer_id: nil,
                                         content_type: 'text',
                        text_content: 'ABC', sorting_order: 1)
      subject.save!
      subject.sorting_order = 2
      subject.valid?
    end
    it { expect(subject.errors[:base].try(:first)).to eq(I18n.t('models.quiz_content.must_assign_to_question_or_answer')) }
  end

  it { should_not validate_presence_of(:quiz_question_id) }
  it { should validate_numericality_of(:quiz_question_id) }

  it { should_not validate_presence_of(:quiz_answer_id) }
  it { should validate_numericality_of(:quiz_answer_id) }

  it { should validate_presence_of(:text_content) }

  it { should validate_presence_of(:sorting_order) }
  it { should validate_numericality_of(:sorting_order) }

  # callbacks
  it { should callback(:process_content_type).before(:save) }
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:check_data_consistency).before(:validation) }

  # scopes
  it { expect(QuizContent).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:content_type=) }
  it { should respond_to(:content_type) }


end
