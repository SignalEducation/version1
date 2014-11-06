require 'rails_helper'

RSpec.describe 'exam_sections/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @exam_level = FactoryGirl.create(:exam_level)
    @exam_section = FactoryGirl.create(:exam_section, exam_level_id: @exam_level.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@exam_section.name}/)
    expect(rendered).to match(/#{@exam_section.name_url}/)
    expect(rendered).to match(/#{@exam_section.exam_level.name}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@exam_section.best_possible_first_attempt_score}/)
  end
end
