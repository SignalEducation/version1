# == Schema Information
#
# Table name: groups
#
#  id                            :integer          not null, primary key
#  name                          :string
#  name_url                      :string
#  active                        :boolean          default(FALSE), not null
#  sorting_order                 :integer
#  description                   :text
#  subject_id                    :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  corporate_customer_id         :integer
#  destroyed_at                  :datetime
#  image_file_name               :string
#  image_content_type            :string
#  image_file_size               :integer
#  image_updated_at              :datetime
#  background_colour             :string
#  background_image_file_name    :string
#  background_image_content_type :string
#  background_image_file_size    :integer
#  background_image_updated_at   :datetime
#

require 'rails_helper'

describe Group do

  # attr-accessible
  black_list = %w(id created_at updated_at destroyed_at background_colour image_content_type image_file_size image_updated_at image_file_name background_image_content_type background_image_file_size background_image_updated_at background_image_file_name)
  Group.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  subject { FactoryGirl.build(:group) }

  # Constants

  # relationships
  it { should have_and_belong_to_many(:subject_courses) }
  it { should have_many(:home_pages) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url) }
  it { should validate_length_of(:name_url).is_at_most(255) }

  it { should validate_presence_of(:description) }

  it { should_not validate_presence_of(:image) }
  it { should_not validate_presence_of(:background_image) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Group).to respond_to(:all_in_order) }
  it { expect(Group).to respond_to(:all_active) }
  it { expect(Group).to respond_to(:for_corporates) }
  it { expect(Group).to respond_to(:for_public) }

  # class methods

  # instance methods
  it { should respond_to(:active_children) }
  it { should respond_to(:children) }
  it { should respond_to(:live_children) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }


end
