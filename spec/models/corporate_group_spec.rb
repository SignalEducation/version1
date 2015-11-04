# == Schema Information
#
# Table name: corporate_groups
#
#  id                    :integer          not null, primary key
#  corporate_customer_id :integer
#  name                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  corporate_manager_id  :integer
#

require 'rails_helper'

describe CorporateGroup do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  CorporateGroup.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:corporate_customer) }
  it { should have_and_belong_to_many(:users) }
  it { should have_many(:corporate_group_grants) }

  # validation
  it { should validate_presence_of(:corporate_customer_id) }
  it { should validate_numericality_of(:corporate_customer_id) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:corporate_customer_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CorporateGroup).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:subject_course_restricted?) }
  it { should respond_to(:subject_course_compulsory?) }

  context "compulsory and restricted flags handling" do
    before do
      @corporate_group = FactoryGirl.create(:corporate_group)
      @compulsory_courses = FactoryGirl.create_list(:active_subject_course, 2, live: true)
      @compulsory_courses.each do |cl|
        @corporate_group.corporate_group_grants.create(subject_course_id: cl.id, compulsory: true)
      end

      @restricted_courses = FactoryGirl.create_list(:active_subject_course, 3, live: true)
      @restricted_courses.each do |rl|
        @corporate_group.corporate_group_grants.create(subject_course_id: rl.id, restricted: true)
      end

    end

    it "returns exact compulsory level IDs" do
      expect(@corporate_group.compulsory_subject_course_ids.count).to eq(@compulsory_courses.length)
      expect(@corporate_group.compulsory_subject_course_ids.sort).to eq(@compulsory_courses.map(&:id).sort)
    end

    it "returns exact restricted level IDs" do
      expect(@corporate_group.restricted_subject_course_ids.count).to eq(@restricted_courses.length)
      expect(@corporate_group.restricted_subject_course_ids.sort).to eq(@restricted_courses.map(&:id).sort)
    end

  end
end
