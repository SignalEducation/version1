# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe UserCountryWorker do
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end

  after do
    Sidekiq::Worker.drain_all
  end

  let(:country) { create(:country) }
  let(:user) { create(:user, country: country) }
  let(:alt_country) { create(:country) }
  let(:ip_address) { Faker::Internet.public_ip_v4_address }

  subject { UserCountryWorker }

  it 'is processed in medium queue.' do
    expect { subject.perform_async(user.id, Faker::Internet.public_ip_v4_address) }.to change(subject.jobs, :size).by(1)
  end

  describe 'internal method calls' do
    subject { UserCountryWorker.new }
    it 'calls #get_country on the IpAddress model' do
      expect(IpAddress).to receive(:get_country).with(ip_address)

      subject.perform(user.id, ip_address)
    end

    it 'does not update the user country if it is not required' do
      allow(IpAddress).to receive(:get_country).and_return(user.country)
      expect(user.country_id).to equal country.id

      subject.perform(user.id, ip_address)

      expect(user.country_id).to equal country.id
    end
  end
end
