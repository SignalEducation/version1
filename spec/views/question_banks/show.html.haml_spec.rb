require 'rails_helper'

RSpec.describe 'question_banks/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:user)
    @exam_level = FactoryGirl.create(:exam_level)
    @question_bank = FactoryGirl.create(:question_bank, user_id: @user.id, exam_level_id: @exam_level.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@question_bank.user.name}/)
    expect(rendered).to match(/#{@question_bank.exam_level.name}/)
    expect(rendered).to match(/#{@question_bank.number_of_questions}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
  end
end
