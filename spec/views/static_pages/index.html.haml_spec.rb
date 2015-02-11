require 'rails_helper'

RSpec.describe 'static_pages/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    temp_static_pages = FactoryGirl.create_list(:static_page, 2)
    @static_pages = StaticPage.paginate(page: 1, per_page: 10)
  end

  xit 'renders a list of static_pages' do
    render
    expect(rendered).to match(/#{@static_pages.first.name.to_s}/)
    expect(rendered).to match(/#{@static_pages.first.publish_from.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/#{@static_pages.first.publish_to.strftime(t('controllers.application.date_formats.standard'))}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@static_pages.first.public_url.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@static_pages.first.created_by.to_s}/)
    expect(rendered).to match(/#{@static_pages.first.updated_by.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@static_pages.first.menu_label.to_s}/)
    expect(rendered).to match(/#{@static_pages.first.tooltip_text.to_s}/)
    expect(rendered).to match(/#{@static_pages.first.language.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@static_pages.first.seo_title.to_s}/)
    expect(rendered).to match(/#{@static_pages.first.seo_description.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/nice_boolean/)
  end
end
