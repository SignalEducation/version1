FactoryGirl.define do
  factory :static_page do
    name "MyString"
publish_from "2014-12-17 09:47:56"
publish_to "2014-12-17 09:47:56"
allow_multiples false
public_url "MyString"
use_standard_page_template false
head_content "MyText"
body_content "MyText"
created_by 1
updated_by 1
add_to_navbar false
add_to_footer false
menu_label "MyString"
tooltip_text "MyString"
language "MyString"
mark_as_noindex false
mark_as_nofollow false
seo_title "MyString"
seo_description "MyString"
approved_country_ids "MyText"
default_page_for_this_url false
make_this_page_sticky false
  end

end
