require 'rails_helper'

RSpec.describe 'question_banks/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:user)
    @exam_level = FactoryGirl.create(:exam_level)
    temp_question_banks = FactoryGirl.create_list(:question_bank, 2, user_id: @user.id, exam_level_id: @exam_level.id)
    @question_banks = QuestionBank.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of question_banks' do
    render
    expect(rendered).to match(/#{@question_banks.first.user.name.to_s}/)
    expect(rendered).to match(/#{@question_banks.first.exam_level.name.to_s}/)
    expect(rendered).to match(/#{@question_banks.first.number_of_questions.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
  end
end
