# == Schema Information
#
# Table name: home_pages
#
#  id                            :integer          not null, primary key
#  seo_title                     :string
#  seo_description               :string
#  subscription_plan_category_id :integer
#  public_url                    :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  subject_course_id             :integer
#  custom_file_name              :string
#  group_id                      :integer
#  name                          :string
#  discourse_ids                 :string
#  home                          :boolean          default(FALSE)
#  header_heading                :string
#  header_paragraph              :text
#  header_button_text            :string
#  background_image              :string
#  header_button_link            :string
#  header_button_subtext         :string
#  footer_link                   :boolean          default(FALSE)
#  mailchimp_list_guid           :string
#  mailchimp_section_heading     :string
#  mailchimp_section_subheading  :string
#  mailchimp_subscribe_section   :boolean          default(FALSE)
#

require 'rails_helper'

describe HomePage do

  # attr-accessible
  black_list = %w(id created_at updated_at discourse_ids)
  HomePage.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  subject { FactoryBot.build(:home_page) }

  # Constants

  # relationships
  it { should belong_to(:subscription_plan_category) }
  it { should belong_to(:group) }
  it { should belong_to(:subject_course) }
  it { should have_many(:blog_posts) }
  it { should have_many(:external_banners) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:seo_title) }
  it { should validate_uniqueness_of(:seo_title) }
  it { should validate_length_of(:seo_title).is_at_most(255) }

  it { should validate_presence_of(:seo_description) }
  it { should validate_length_of(:seo_description).is_at_most(255) }

  it { should validate_presence_of(:public_url) }
  it { should validate_uniqueness_of(:public_url) }
  it { should validate_length_of(:public_url).is_at_most(255) }

  it { should_not validate_presence_of(:custom_file_name) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(HomePage).to respond_to(:all_in_order) }
  it { expect(HomePage).to respond_to(:for_courses) }
  it { expect(HomePage).to respond_to(:for_groups) }
  it { expect(HomePage).to respond_to(:for_footer) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:default_home_page) }
  it { should respond_to(:course) }

end
