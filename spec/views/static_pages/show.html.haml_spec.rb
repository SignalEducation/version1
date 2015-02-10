require 'rails_helper'

RSpec.describe 'static_pages/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @static_page = FactoryGirl.create(:static_page)
  end

  xit 'renders attributes' do
    render
    expect(rendered).to match(/#{@static_page.name}/)
    expect(rendered).to match(/#{@static_page.publish_from.to_s(:standard)}/)
    expect(rendered).to match(/#{@static_page.publish_to.to_s(:standard)}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@static_page.public_url}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@static_page.head_content}/)
    expect(rendered).to match(/#{@static_page.body_content}/)
    expect(rendered).to match(/#{@static_page.created_by}/)
    expect(rendered).to match(/#{@static_page.updated_by}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@static_page.menu_label}/)
    expect(rendered).to match(/#{@static_page.tooltip_text}/)
    expect(rendered).to match(/#{@static_page.language}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@static_page.seo_title}/)
    expect(rendered).to match(/#{@static_page.seo_description}/)
    expect(rendered).to match(/#{@static_page.approved_country_ids}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
  end
end
