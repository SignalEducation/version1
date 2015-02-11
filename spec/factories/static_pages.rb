# == Schema Information
#
# Table name: static_pages
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  publish_from               :datetime
#  publish_to                 :datetime
#  allow_multiples            :boolean          default(FALSE), not null
#  public_url                 :string(255)
#  use_standard_page_template :boolean          default(FALSE), not null
#  head_content               :text
#  body_content               :text
#  created_by                 :integer
#  updated_by                 :integer
#  add_to_navbar              :boolean          default(FALSE), not null
#  add_to_footer              :boolean          default(FALSE), not null
#  menu_label                 :string(255)
#  tooltip_text               :string(255)
#  language                   :string(255)
#  mark_as_noindex            :boolean          default(FALSE), not null
#  mark_as_nofollow           :boolean          default(FALSE), not null
#  seo_title                  :string(255)
#  seo_description            :string(255)
#  approved_country_ids       :text
#  default_page_for_this_url  :boolean          default(FALSE), not null
#  make_this_page_sticky      :boolean          default(FALSE), not null
#  logged_in_required         :boolean          default(FALSE), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  show_standard_footer       :boolean          default(TRUE)
#

FactoryGirl.define do
  factory :static_page do
    name 'MyString'
    publish_from '2014-12-17 09:47:56'
    publish_to 1.month.from_now
    allow_multiples false
    sequence(:public_url) { |n| "/url-#{n}" }
    use_standard_page_template true
    head_content ''
    body_content 'bodyContent'
    created_by 1
    updated_by 1
    add_to_navbar false
    add_to_footer false
    menu_label 'MyString'
    tooltip_text 'MyString'
    language 'en'
    mark_as_noindex false
    mark_as_nofollow false
    seo_title 'MyString'
    seo_description 'MyString'
    approved_country_ids [1,2]
    default_page_for_this_url false
    make_this_page_sticky false
    logged_in_required false
    show_standard_footer true
    factory :landing_page do
      public_url '/'
      body_content "<div class=\"container\">\r\n  <div class=\"row\">\r\n    <div class=\"col-sm-12 text-center\">\r\n      <h1>Welcome to Learn Signal</h1>\r\n    </div>\r\n  </div>\r\n</div>"
    end
  end

end
