# == Schema Information
#
# Table name: ip_addresses
#
#  id           :integer          not null, primary key
#  ip_address   :string(255)
#  latitude     :float
#  longitude    :float
#  country_id   :integer
#  alert_level  :integer
#  created_at   :datetime
#  updated_at   :datetime
#  rechecked_on :datetime
#

require 'rails_helper'

describe IpAddress do
  subject { FactoryBot.build(:ip_address) }

  # Constants

  # relationships
  it { should belong_to(:country) }

  # validation
  it { should validate_presence_of(:ip_address) }
  it { should validate_uniqueness_of(:ip_address).case_insensitive }
  it { should validate_length_of(:ip_address).is_at_most(255) }

  it { should validate_presence_of(:latitude) }

  it { should validate_presence_of(:longitude) }

  # callbacks
  it { should callback(:geo_locate).before(:validation).on(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(IpAddress).to respond_to(:all_in_order) }

  # class methods
  it { expect(IpAddress).to respond_to(:get_country) }

  # instance methods
  it { should respond_to(:destroyable?) }

  describe 'Class Methods' do
    describe '.get_country' do
      let!(:address) { create(:ip_address) }
      let(:country) { build_stubbed(:country) }
      let!(:uk) { create(:country, name: 'United Kingdom') }

      it 'returns the first IP address that matches the input IP address' do
        expect(IpAddress).not_to receive(:create)
        expect(IpAddress.get_country(address.ip_address)).to eq address.country
      end

      it 'creates a new IP address record if none matching exists' do
        expect(IpAddress).to receive(:create).and_return(double(country: 'Test Country'))

        IpAddress.get_country('334.545.66.7')
      end

      it 'returns the United Kingdom as the country if no country exists for the IP' do
        expect(IpAddress.get_country('334.545.66.7', true)).to eq uk
      end
    end
  end

  describe 'Instance Methods' do
    describe '#assign_country_from_geo' do
      let(:ip_address) { build_stubbed(:ip_address) }
      let(:country) { create(:country) }

      it 'assigns the country_id to 78 (UK) if the result is NIL' do
        expect(ip_address).to receive(:country_id=).with(78)

        ip_address.assign_country_from_geo(nil)
      end

      it 'assigns the country_id to the ID of the country returned by the Geocoder' do
        expect(ip_address).to receive(:country_id=).with(country.id)

        ip_address.assign_country_from_geo(double(country_code: country.iso_code))
      end
    end

    describe '#destroyable?' do
      let(:ip_address) { build_stubbed(:ip_address) }

      it 'returns TRUE' do
        expect(ip_address.destroyable?).to eq true
      end
    end

    describe '#check_dependencies' do
      let(:ip_address) { build_stubbed(:ip_address) }

      it 'returns NIL' do
        expect(ip_address.send(:check_dependencies)).to be_nil
      end

      it 'returns FALSE if the record is NOT destroyable' do
        allow(ip_address).to receive(:destroyable?).and_return(false)

        expect(ip_address.send(:check_dependencies)).to be false
      end
    end

    describe '#geo_locate' do
      let(:address) { build(:ip_address) }

      it 'sets the alert level' do
        expect(address).to receive(:alert_level=).with(0)

        address.send(:geo_locate)
      end

      it 'skips geocoding for the test environment' do
        expect(address).not_to receive(:geocode)
        expect(address).not_to receive(:reverse_geocode)

        address.send(:geo_locate)
      end

      it 'calls geocoding for non-test environment' do
        allow(Rails.env).to receive(:test?).and_return(false)
        expect(address).to receive(:geocode)
        expect(address).to receive(:reverse_geocode)

        address.send(:geo_locate)
      end

      it 'is called before a record is validated' do
        expect(address).to receive(:geo_locate)

        address.valid?
      end

      it 'is not called before validation on update' do
        record = create(:ip_address)
        expect(record).not_to receive(:geo_locate)

        record.update(alert_level: 9)
      end
    end
  end
end
