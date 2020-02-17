FactoryBot.define do
  factory :system_setting do
    environment { 'test' }
    settings { { 'vimeo_as_main_player?': 'true' } }
  end
end
