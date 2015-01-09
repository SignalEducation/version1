require 'rails_helper'

RSpec.describe 'static_pages/edit', type: :view do
  before(:each) do
    @static_page = FactoryGirl.create(:static_page)
  end

  xit 'renders new static_page form' do
    render
    assert_select 'form[action=?][method=?]', static_page_path(id: @static_page.id), 'post' do
      assert_select 'input#static_page_name[name=?]', 'static_page[name]'
      assert_select 'input#static_page_publish_from[name=?]', 'static_page[publish_from]'
      assert_select 'input#static_page_publish_to[name=?]', 'static_page[publish_to]'
      assert_select 'input#static_page_allow_multiples[name=?]', 'static_page[allow_multiples]'
      assert_select 'input#static_page_public_url[name=?]', 'static_page[public_url]'
      assert_select 'input#static_page_use_standard_page_template[name=?]', 'static_page[use_standard_page_template]'
      assert_select 'textarea#static_page_head_content[name=?]', 'static_page[head_content]'
      assert_select 'textarea#static_page_body_content[name=?]', 'static_page[body_content]'
      assert_select 'input#static_page_created_by[name=?]', 'static_page[created_by]'
      assert_select 'input#static_page_updated_by[name=?]', 'static_page[updated_by]'
      assert_select 'input#static_page_add_to_navbar[name=?]', 'static_page[add_to_navbar]'
      assert_select 'input#static_page_add_to_footer[name=?]', 'static_page[add_to_footer]'
      assert_select 'input#static_page_menu_label[name=?]', 'static_page[menu_label]'
      assert_select 'input#static_page_tooltip_text[name=?]', 'static_page[tooltip_text]'
      assert_select 'input#static_page_language[name=?]', 'static_page[language]'
      assert_select 'input#static_page_mark_as_noindex[name=?]', 'static_page[mark_as_noindex]'
      assert_select 'input#static_page_mark_as_nofollow[name=?]', 'static_page[mark_as_nofollow]'
      assert_select 'input#static_page_seo_title[name=?]', 'static_page[seo_title]'
      assert_select 'input#static_page_seo_description[name=?]', 'static_page[seo_description]'
      assert_select 'textarea#static_page_approved_country_ids[name=?]', 'static_page[approved_country_ids]'
      assert_select 'input#static_page_default_page_for_this_url[name=?]', 'static_page[default_page_for_this_url]'
      assert_select 'input#static_page_make_this_page_sticky[name=?]', 'static_page[make_this_page_sticky]'
    end
  end
end
