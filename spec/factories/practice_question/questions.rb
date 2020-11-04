# frozen_string_literal: true

# == Schema Information
#
# Table name: practice_question_questions
#
#  id                          :bigint           not null, primary key
#  kind                        :integer
#  content                     :json
#  solution                    :json
#  sorting_order               :integer
#  course_practice_question_id :bigint
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  description                 :text
#
FactoryBot.define do
  factory :practice_question_questions, class: ::PracticeQuestion::Question do
    kind     { ::PracticeQuestion::Question.kinds.keys.sample }
    content  { { text: Faker::Lorem.sentence } }
    solution { { text: Faker::Lorem.sentence } }
    sequence(:sorting_order)

    trait :with_question do
      association :practice_question, factory: :course_practice_question
    end

    trait :spreadsheet_question do
      kind    { :spreadsheet }
      content {
        { 'content' =>
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
                  '9' => { '2' => { 'value' => 'asdsas' } }
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
        }.to_json
      }
      solution {
        { 'solution' =>
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
                  '9' => { '2' => { 'value' => 'asdsas' } }
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
        }.to_json
      }
    end
  end
end
