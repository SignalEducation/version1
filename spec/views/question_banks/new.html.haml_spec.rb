require 'rails_helper'

RSpec.describe 'question_banks/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:user)
    @users = User.all
    x = FactoryGirl.create(:exam_level)
    @exam_levels = ExamLevel.all
    @question_bank = FactoryGirl.build(:question_bank)
  end

  xit 'renders edit question_bank form' do
    render
    assert_select 'form[action=?][method=?]', question_banks_path, 'post' do
      assert_select 'select#question_bank_user_id[name=?]', 'question_bank[user_id]'
      assert_select 'select#question_bank_exam_level_id[name=?]', 'question_bank[exam_level_id]'
      assert_select 'input#question_bank_number_of_questions[name=?]', 'question_bank[number_of_questions]'
      assert_select 'input#question_bank_easy_questions[name=?]', 'question_bank[easy_questions]'
      assert_select 'input#question_bank_medium_questions[name=?]', 'question_bank[medium_questions]'
      assert_select 'input#question_bank_hard_questions[name=?]', 'question_bank[hard_questions]'
    end
  end
end
