# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KeyArea, type: :model do
  let!(:key_area) { create(:key_area, :active) }

  describe 'Should Respond' do
    it { should respond_to(:group_id) }
    it { should respond_to(:name) }
    it { should respond_to(:active) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  # relationships
  it { should belong_to(:group) }
  it { should have_many(:courses) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:group_id).with_message('must be unique within the group') }

  # scopes
  it { expect(KeyArea).to respond_to(:all_in_order) }
  it { expect(KeyArea).to respond_to(:all_active) }

  # instance methods
  it { should respond_to(:destroyable?) }

  describe '#destroyable?' do
    context 'always return true' do
      it { expect(key_area).to be_destroyable }
    end
  end

  describe '.search' do
    context 'return should find key_area by name' do
      it { expect(KeyArea.search(key_area.name.first(3))).to include(key_area) }
      it { expect(KeyArea.search(key_area.name.last(2))).to include(key_area) }
    end

    context 'return should find key_area without any search' do
      it { expect(KeyArea.search(nil)).to include(key_area) }
    end
  end
end
