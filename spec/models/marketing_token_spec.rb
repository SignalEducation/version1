# == Schema Information
#
# Table name: marketing_tokens
#
#  id                    :integer          not null, primary key
#  code                  :string
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
  it { expect(MarketingToken.const_defined?(:SYSTEM_TOKEN_CODES)).to eq(true) }

  # relationships
  it { should belong_to(:marketing_category) }

  # validation
  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:code).case_insensitive }
  it { should validate_length_of(:code).is_at_most(255) }

  it { should validate_presence_of(:marketing_category_id) }

  # callbacks

  # scopes
  it { expect(MarketingToken).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:editable?) }

  describe 'check CSV consistency' do
    let!(:category) { FactoryGirl.create(:marketing_category) }

    it 'should set error message for invalid fields count' do
      csv_data, has_errors = MarketingToken.parse_csv('abcd')
      expect(csv_data.first[:error_messages]).to include(I18n.t('models.marketing_tokens.invalid_field_count'))
      expect(has_errors).to eq(true)

      csv_data, has_errors = MarketingToken.parse_csv('abcd,Fake category')
      expect(csv_data.first[:error_messages]).to include(I18n.t('models.marketing_tokens.invalid_field_count'))
      expect(has_errors).to eq(true)

      csv_data, has_errors = MarketingToken.parse_csv('abcd,Fake category,true,1')
      expect(csv_data.first[:error_messages]).to include(I18n.t('models.marketing_tokens.invalid_field_count'))
      expect(has_errors).to eq(true)
    end

    it 'should set error message if system token name was submitted' do
      csv_data, has_errors = MarketingToken.parse_csv("#{MarketingToken::SYSTEM_TOKEN_CODES.first},#{category.name},true")
      expect(csv_data.first[:error_messages]).to include(I18n.t('models.marketing_tokens.cannot_change_system_token'))
      expect(has_errors).to eq(true)
    end

    it 'should set error message if marketing category with given name does not exist' do
      csv_data, has_errors = MarketingToken.parse_csv('aykh001,Fake Category,true')
      expect(csv_data.first[:error_messages]).to include(I18n.t('models.marketing_tokens.invalid_marketing_category_name'))
      expect(has_errors).to eq(true)
    end

    it "should set error message if 'is_hard' flag value is not valid" do
      csv_data, has_errors = MarketingToken.parse_csv("aykh001,#{category.name},1")
      expect(csv_data.first[:error_messages]).to include(I18n.t('models.marketing_tokens.invalid_flag_value'))
      expect(has_errors).to eq(true)
    end

    it "should set error message if duplicated codes are found" do
      csv_data, has_errors = MarketingToken.parse_csv("baidu,#{category.name},1\nbing,#{category.name},1\nbaidu,#{category.name},0\n")
      expect(csv_data.last[:error_messages]).to include(I18n.t('models.marketing_tokens.duplicated_token_code'))
      expect(has_errors).to eq(true)
    end

    it 'should return array with requested number of tokens data and no error messages' do
      csv_data, has_errors = MarketingToken.parse_csv("aykh001,#{category.name},true\n0002,#{category.name},false")
      expect(csv_data.length).to eq(2)
      csv_data.each { |csd| expect(csd[:error_messages]).to be_empty }
      expect(has_errors).to eq(false)
    end
  end

  describe 'bulk tokens creation' do
    let!(:category) { FactoryGirl.create(:marketing_category) }
    let!(:valid_data) {
      {
        '0' => {'code' => 'abyh001', 'category' => category.name, 'flag' => 'true'},
        '1' => {'code' => 'yhko002', 'category' => category.name, 'flag' => 'false'}
      }
    }

    it 'should not import any token if any group name is not valid' do
      expect{MarketingToken.bulk_create(valid_data.merge({'2' => {'code' => '001', 'category' => 'Dummy', 'flag' => 'true'}}))}
        .to change {MarketingToken.count}.by(0)
    end

    it 'should not import any token if any token code is not valid' do
      expect{MarketingToken.bulk_create(valid_data.merge({'2' => {'code' => '   ', 'category' => 'Dummy', 'flag' => 'true'}}))}
        .to change {MarketingToken.count}.by(0)
      expect{MarketingToken.bulk_create(valid_data.merge({'2' => {'code' => nil, 'category' => 'Dummy', 'flag' => 'true'}}))}
        .to change {MarketingToken.count}.by(0)
    end

    it 'should not import any token if duplicated tokens are submitted' do
      expect{MarketingToken.bulk_create(valid_data.merge({'2' => {'code' => 'abyh001', 'category' => category.name, 'flag' => 'true'}}))}
        .to change {MarketingToken.count}.by(0)
    end

    it 'should not import any token token code is system defined' do
      expect{MarketingToken.bulk_create(valid_data.merge({'2' => {'code' => MarketingToken::SYSTEM_TOKEN_CODES.first, 'category' => 'Dummy', 'flag' => 'true'}}))}
        .to change {MarketingToken.count}.by(0)
    end

    it 'should import valid data' do
      tokens = MarketingToken.bulk_create(valid_data)
      expect(tokens.length).to eq(valid_data.keys.length)
    end
  end
end
