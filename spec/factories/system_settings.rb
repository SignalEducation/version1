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
FactoryBot.define do
  factory :system_setting do
    environment { 'test' }
    settings { { 'vimeo_as_main_player?': 'true' } }
  end
end
