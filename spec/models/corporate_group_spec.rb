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
  it { should respond_to(:exam_level_restricted?) }
  it { should respond_to(:exam_level_compulsory?) }
  it { should respond_to(:exam_section_restricted?) }
  it { should respond_to(:exam_section_compulsory?) }

  context "compulsory and restricted flags handling" do
    before do
      @corporate_group = FactoryGirl.create(:corporate_group)
      @compulsory_levels = FactoryGirl.create_list(:active_exam_level, 2, live: true)
      @compulsory_levels.each do |cl|
        @corporate_group.corporate_group_grants.create(exam_level_id: cl.id, compulsory: true)
      end

      @restricted_levels = FactoryGirl.create_list(:active_exam_level, 3, live: true)
      @restricted_levels.each do |rl|
        @corporate_group.corporate_group_grants.create(exam_level_id: rl.id, restricted: true)
      end

      @compulsory_sections = FactoryGirl.create_list(:active_exam_section, 4, live: true)
      @compulsory_sections.each do |cs|
        @corporate_group.corporate_group_grants.create(exam_section_id: cs.id, compulsory: true)
      end

      @restricted_sections = FactoryGirl.create_list(:active_exam_section, 5, live: true)
      @restricted_sections.each do |rs|
        @corporate_group.corporate_group_grants.create(exam_section_id: rs.id, restricted: true)
      end
    end

    it "returns exact compulsory level IDs" do
      expect(@corporate_group.compulsory_level_ids.count).to eq(@compulsory_levels.length)
      expect(@corporate_group.compulsory_level_ids.sort).to eq(@compulsory_levels.map(&:id).sort)
    end

    it "returns exact restricted level IDs" do
      expect(@corporate_group.restricted_level_ids.count).to eq(@restricted_levels.length)
      expect(@corporate_group.restricted_level_ids.sort).to eq(@restricted_levels.map(&:id).sort)
    end

    it "returns exact compulsory section IDs" do
      expect(@corporate_group.compulsory_section_ids.count).to eq(@compulsory_sections.length)
      expect(@corporate_group.compulsory_section_ids.sort).to eq(@compulsory_sections.map(&:id).sort)
    end

    it "returns exact restricted section IDs" do
      expect(@corporate_group.restricted_section_ids.count).to eq(@restricted_sections.length)
      expect(@corporate_group.restricted_section_ids.sort).to eq(@restricted_sections.map(&:id).sort)
    end
  end
end
