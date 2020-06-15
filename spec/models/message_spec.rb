# == Schema Information
#
# Table name: messages
#
#  id              :bigint           not null, primary key
#  user_id         :integer
#  opens           :integer
#  clicks          :integer
#  kind            :integer          default("0"), not null
#  process_at      :datetime
#  template        :string
#  mandrill_id     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  state           :string
#  template_params :hstore
#
require 'rails_helper'

describe Message do

  describe 'Should Respond' do
    it { should respond_to(:user_id) }
    it { should respond_to(:opens) }
    it { should respond_to(:clicks) }
    it { should respond_to(:kind) }
    it { should respond_to(:process_at) }
    it { should respond_to(:template) }
    it { should respond_to(:mandrill_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
    it { should respond_to(:state) }
    it { should respond_to(:template_params) }
  end

  describe 'Constants' do
    it { expect(Message.const_defined?(:STATES)).to eq(true) }
  end

  describe 'Associations' do
    it { should belong_to(:user) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:kind) }

    it { should validate_presence_of(:state).on(:update) }
    it { should validate_inclusion_of(:state).in_array(Message::STATES).on(:update) }

    it { should validate_presence_of(:process_at) }
    it { should validate_presence_of(:template) }
    it { should validate_presence_of(:mandrill_id).on(:update) }
  end

  it { expect(Message).to respond_to(:process_webhook_event) }
end
