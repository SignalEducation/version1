# == Schema Information
#
# Table name: static_pages
#
#  id                            :integer          not null, primary key
#  name                          :string
#  publish_from                  :datetime
#  publish_to                    :datetime
#  allow_multiples               :boolean          default(FALSE), not null
#  public_url                    :string
#  use_standard_page_template    :boolean          default(FALSE), not null
#  head_content                  :text
#  body_content                  :text
#  created_by                    :integer
#  updated_by                    :integer
#  add_to_navbar                 :boolean          default(FALSE), not null
#  add_to_footer                 :boolean          default(FALSE), not null
#  menu_label                    :string
#  tooltip_text                  :string
#  language                      :string
#  mark_as_noindex               :boolean          default(FALSE), not null
#  mark_as_nofollow              :boolean          default(FALSE), not null
#  seo_title                     :string
#  seo_description               :string
#  approved_country_ids          :text
#  default_page_for_this_url     :boolean          default(FALSE), not null
#  make_this_page_sticky         :boolean          default(FALSE), not null
#  logged_in_required            :boolean          default(FALSE), not null
#  created_at                    :datetime
#  updated_at                    :datetime
#  show_standard_footer          :boolean          default(TRUE)
#  post_sign_up_redirect_url     :string
#  subscription_plan_category_id :integer
#  student_sign_up_h1            :string
#  student_sign_up_sub_head      :string
#

require 'rails_helper'

describe StaticPage do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  StaticPage.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  subject { FactoryGirl.build(:static_page) }

  # Constants
  #it { expect(StaticPage.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:creator) }
  it { should belong_to(:updater) }
  it { should have_many(:static_page_uploads) }
  it { should belong_to(:subscription_plan_category) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:publish_from) }

  it { should validate_presence_of(:public_url) }
  it { should validate_uniqueness_of(:public_url) }
  it { should validate_length_of(:public_url).is_at_most(255) }

  it { should validate_presence_of(:body_content) }

  it { should validate_presence_of(:created_by) }

  it { should validate_presence_of(:updated_by).on(:update) }

  describe 'menu labels and tooltip are required when it appears in the navbar' do
    before :each do
      allow(subject).to receive(:add_to_navbar).and_return(true)
    end
    it { should validate_presence_of(:menu_label) }
    it { should validate_length_of(:menu_label).is_at_most(255) }
    it { should validate_presence_of(:tooltip_text) }
    it { should validate_length_of(:tooltip_text).is_at_most(255) }
  end

  describe 'menu labels and tooltip are required when it appears in the navbar' do
    before :each do
      allow(subject).to receive(:add_to_navbar).and_return(true)
    end
    it { should validate_presence_of(:menu_label) }
    it { should validate_presence_of(:tooltip_text) }
  end

  it { should_not validate_presence_of(:menu_label) }
  it { should_not validate_presence_of(:tooltip_text) }

  it { should validate_presence_of(:language) }
  it { should validate_length_of(:language).is_at_most(255) }

  it { should validate_presence_of(:seo_title) }
  it { should validate_length_of(:seo_title).is_at_most(255) }

  it { should validate_presence_of(:seo_description) }
  it { should validate_length_of(:seo_description).is_at_most(255) }

  it { should_not validate_presence_of(:subscription_plan_category_id) }

  it { should validate_length_of(:post_sign_up_redirect_url).is_at_most(255) }
  it { should validate_length_of(:student_sign_up_h1).is_at_most(255) }
  it { should validate_length_of(:student_sign_up_sub_head).is_at_most(255) }

  # callbacks
  it { should callback(:sanitize_public_url).before(:save) }
  it { should callback(:sanitize_country_ids).before(:save) }
  it { should callback(:update_default_for_related_pages).after(:save) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(StaticPage).to respond_to(:all_in_order) }
  it { expect(StaticPage).to respond_to(:all_active) }
  it { expect(StaticPage).to respond_to(:all_for_language) }
  it { expect(StaticPage).to respond_to(:all_for_country) }

  # class methods
  it { expect(StaticPage).to respond_to(:all_of_type) }
  it { expect(StaticPage).to respond_to(:find_active_default_for_url) }
  it { expect(StaticPage).to respond_to(:with_logged_in_status) }

  # instance methods
  it { should respond_to(:destroyable?) }

end
