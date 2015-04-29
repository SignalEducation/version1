# == Schema Information
#
# Table name: marketing_tokens
#
#  id                    :integer          not null, primary key
#  code                  :string(255)
#  marketing_category_id :integer
#  is_hard               :boolean          default(FALSE), not null
#  is_direct             :boolean          default(FALSE), not null
#  is_seo                :boolean          default(FALSE), not null
#  created_at            :datetime
#  updated_at            :datetime
#

require 'rails_helper'

describe MarketingToken do

  # attr-accessible
  black_list = %w(id is_direct is_seo created_at updated_at)
  MarketingToken.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(MarketingToken.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:marketing_category) }

  # validation
  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:code).case_insensitive }

  it { should validate_presence_of(:marketing_category_id) }
  it { should validate_numericality_of(:marketing_category_id) }

  # callbacks

  # scopes
  it { expect(MarketingToken).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:editable?) }

  describe "CSV import" do
    let!(:category) { FactoryGirl.create(:marketing_category) }

    it "should not process line with one field" do
      expect {MarketingToken.import("abcd")}.to_not change {MarketingToken.count}
    end

    it "should not change system defined token" do
      sys_token = FactoryGirl.create(:marketing_token, code: "seo")
      MarketingToken.import("seo,#{category.name},true")
      expect(sys_token.reload.is_hard).to eq(false)
    end

    it "should change is_token flag to true for existing token" do
      token = FactoryGirl.create(:marketing_token, marketing_category_id: category.id)
      MarketingToken.import("#{token.code},#{category.name},true")
      expect(token.reload.is_hard).to eq(true)
    end

    it "should create tokens if they do not exist" do
      token = FactoryGirl.create(:marketing_token, marketing_category_id: category.id)
      csv = "123,#{category.name},false\nabc,#{category.name},true"
      expect { MarketingToken.import(csv) }.to change { MarketingToken.count }.by(2)
    end
  end
end
