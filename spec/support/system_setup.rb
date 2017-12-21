require 'rails_helper'

shared_context 'system_setup' do

  # currencies
  let!(:gbp) { FactoryGirl.create(:gbp) }
  let!(:eur) { FactoryGirl.create(:euro) }
  let!(:usd) { FactoryGirl.create(:usd) }

  # countries
  let!(:uk) { FactoryGirl.create(:uk, currency_id: gbp.id) }
  let!(:ireland) { FactoryGirl.create(:ireland, currency_id: eur.id) }
  let!(:usa) { FactoryGirl.create(:usa, currency_id: usd.id) }

  # homepages
  let!(:home) { FactoryGirl.create(:home) }
  let!(:landing_page_1) { FactoryGirl.create(:landing_page_1) }

end
