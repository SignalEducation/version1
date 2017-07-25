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
#

require 'rails_helper'

describe HomePage do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  HomePage.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:subject_course) }
  it { should belong_to(:subscription_plan_category) }

  # validation
  it { should validate_presence_of(:seo_title) }

  it { should validate_presence_of(:seo_description) }

  it { should validate_presence_of(:public_url) }

  it { should_not validate_presence_of(:custom_file_name) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(HomePage).to respond_to(:all_in_order) }
  it { expect(HomePage).to respond_to(:for_courses) }

  # class methods

  # instance methods
  it { should respond_to(:default_home_page) }
  it { should respond_to(:destroyable?) }

end
