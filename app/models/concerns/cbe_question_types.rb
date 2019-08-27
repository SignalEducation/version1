# frozen_string_literal: true

module CbeQuestionTypes
  extend ActiveSupport::Concern

  included do
    enum kind: { multiple_choice: 0,
                 multiple_response: 1,
                 complete: 2,
                 fill_in_the_blank: 3,
                 drag_drop: 4,
                 dropdown_list: 5,
                 hot_spot: 6,
                 spreadsheet: 7,
                 open: 8 }
  end
end
