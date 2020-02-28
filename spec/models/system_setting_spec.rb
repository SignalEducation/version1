# == Schema Information
#
# Table name: system_settings
#
#  id          :bigint           not null, primary key
#  environment :string
#  settings    :hstore
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe SystemSetting, type: :model do
  let!(:_system) { build(:system_setting) }

  describe 'Should Respond' do
    it { should respond_to(:environment) }
    it { should respond_to(:settings) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:environment) }
    it { should validate_presence_of(:settings) }
    it do
      SystemSetting.new(environment: 'whatever', settings: {}).save!(validate: false)
      should validate_uniqueness_of(:environment)
    end
  end

  describe 'Factory' do
    it { expect(_system).to be_a SystemSetting }
    it { expect(_system).to be_valid }
  end
end
