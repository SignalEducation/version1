# == Schema Information
#
# Table name: exercises
#
#  id                      :bigint(8)        not null, primary key
#  product_id              :bigint(8)
#  state                   :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint(8)
#  corrector_id            :bigint(8)
#  submission_file_name    :string
#  submission_content_type :string
#  submission_file_size    :bigint(8)
#  submission_updated_at   :datetime
#  correction_file_name    :string
#  correction_content_type :string
#  correction_file_size    :bigint(8)
#  correction_updated_at   :datetime
#  submitted_on            :datetime
#  corrected_on            :datetime
#  returned_on             :datetime
#

require 'rails_helper'
require Rails.root.join "spec/concerns/filterable_spec.rb"

RSpec.describe Exercise, type: :model do
  it_behaves_like "filterable"

  describe '.search_scopes' do
    it 'has the correct search_scopes' do
      expect(Exercise.search_scopes).to eq(
        [:state, :product, :corrector, :search]
      )
    end
  end

  it 'has a valid factory' do
    expect(build(:exercise)).to be_valid
  end
end
