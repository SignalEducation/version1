# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_exhibits
#
#  id                    :bigint           not null, primary key
#  name                  :string
#  kind                  :integer
#  content               :json
#  sorting_order         :integer
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :bigint
#  document_updated_at   :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  cbe_scenario_id       :bigint
#

FactoryBot.define do
  factory :cbe_exhibits, class: Cbe::Exhibit do
    name     { Faker::Lorem.word }
    kind     { Cbe::Exhibit.kinds.keys.sample }
    sequence(:sorting_order)

    trait :with_scenario do
      association :scenario, :with_section, factory: :cbe_scenario
    end

    trait :with_pdf do
      kind     { :pdf }
      document { File.new(Rails.root.join('spec', 'support', 'fixtures', 'file.pdf')) }
    end

    trait :with_spreadsheet do
      kind { :spreadsheet }
      content { { 'content' =>
                  {
                    'data' => {
                      'name' => 'Sheet1',
                      'isSelected' => true,
                      'activeRow' => 7,
                      'activeCol' => 2,
                      'theme' => 'Office',
                      'data' => {
                        'dataTable' => {
                          '4' => {
                            '1' => { 'value' => 'dsa' },
                            '2' => { 'value' => 'dad' }
                          },
                          '7' => {
                            '0' => { 'value' => 'dadas' },
                            '2' => { 'value' => 'ad' }
                          },
                          '9' => { '2' => {'value' => 'asdsas'} }
                        },
                        'defaultDataNode' => { 'style' => { 'themeFont' => 'Body' } }
                      },
                      'rowHeaderData' => {
                        'defaultDataNode' => { 'style' => { 'themeFont' => 'Body' } }
                      },
                      'colHeaderData' => {
                        'defaultDataNode' => { 'style' => { 'themeFont' => 'Body' } }
                      },
                      'leftCellIndex' => 0,
                      'topCellIndex' => 0,
                      'selections' => {
                        '0' => { 'row' => 7, 'rowCount' => 1, 'col' => 2, 'colCount' => 1 },
                        'length' => 1
                      },
                      'cellStates' => {},
                      'outlineColumnOptions' => {},
                      'autoMergeRangeInfos' => []
                    }
                  }
                }.to_json }
    end
  end
end
