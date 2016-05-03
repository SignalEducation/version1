# == Schema Information
#
# Table name: groups
#
#  id                    :integer          not null, primary key
#  name                  :string
#  name_url              :string
#  active                :boolean          default(FALSE), not null
#  sorting_order         :integer
#  description           :text
#  subject_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  corporate_customer_id :integer
#  destroyed_at          :datetime
#  image_file_name       :string
#  image_content_type    :string
#  image_file_size       :integer
#  image_updated_at      :datetime
#  background_colour     :string
#

require 'rails_helper'

describe Group do

  # attr-accessible
  black_list = %w(id created_at updated_at corporate_customer_id destroyed_at image_content_type image_file_size image_updated_at image_file_name)
  Group.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  subject { FactoryGirl.build(:group) }

  # Constants
  #it { expect(Group.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should have_and_belong_to_many(:subject_courses) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url) }
  it { should validate_length_of(:name_url).is_at_most(255) }

  it { should validate_presence_of(:description) }

  it { should_not validate_presence_of(:image) }
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
  it { should respond_to(:destroyable?) }


end
