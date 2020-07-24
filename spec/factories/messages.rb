# == Schema Information
#
# Table name: messages
#
#  id                    :bigint           not null, primary key
#  user_id               :integer
#  opens                 :integer
#  clicks                :integer
#  kind                  :integer          default("0"), not null
#  process_at            :datetime
#  template              :string
#  mandrill_id           :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  state                 :string
#  template_params       :hstore
#  guid                  :string
#  onboarding_process_id :integer
#
FactoryBot.define do
  factory :message do
    opens           { 1 }
    clicks          { 1 }
    kind            { 2 }
    process_at      { Time.zone.now }
    template        { 'template' }
    mandrill_id     { '123456abcdef' }
    state           { 'sent' }
    template_params { { 'url': 'abcdefghijklmnopqrstuvwxyz' } }
    guid            { SecureRandom.hex(15) }
    association     :user
  end
end
