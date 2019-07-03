require 'rails_helper'

RSpec.describe CbeMultipleChoiceQuestion, type: :model do

  context 'When creating Multiple choice questions with default settings' do
    it 'There should be no ActiveRecord Errors' do
      cbe = Cbe.create(name: 'BCCA EXAM', title: 'exam 1', description: 'test desc', exam_body_id: 1)
      cbe_section = CbeSection.create(name: 'Intro',
                                      scenario_label: 'S Label',
                                      scenario_description: 'S Desc',
                                      cbe: cbe)
      cbe_question_grouping = CbeQuestionGrouping.create(cbe_section_id: cbe_section.id, cbe_id: cbe.id)
      cbe_question_grouping.id
      cbe_question1 = CbeMultipleChoiceQuestion.create(label: 'Choice 1',
                                                       is_correct_answer: false,
                                                       order: 1,
                                                       cbe_question_grouping_id: cbe_question_grouping.id)
      cbe_question2 = CbeMultipleChoiceQuestion.create(label: 'Choice 2',
                                                       is_correct_answer: false,
                                                       order: 2,
                                                       cbe_question_grouping_id: cbe_question_grouping.id)
      cbe_question3 = CbeMultipleChoiceQuestion.create(label: 'Choice 3',
                                                       is_correct_answer: false,
                                                       order: 3,
                                                       cbe_question_grouping_id: cbe_question_grouping.id)
      cbe_question4 = CbeMultipleChoiceQuestion.create(label: 'Choice 4',
                                                       is_correct_answer: false,
                                                       order: 4,
                                                       cbe_question_grouping_id: cbe_question_grouping.id)


      expect(cbe_question1.errors.blank?).to eq true
      expect(cbe_question2.errors.blank?).to eq true
      expect(cbe_question3.errors.blank?).to eq true
      expect(cbe_question4.errors.blank?).to eq true
    end
  end


end
