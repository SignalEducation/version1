# == Schema Information
#
# Table name: exercises
#
#  id         :bigint(8)        not null, primary key
#  product_id :bigint(8)
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Exercise < ApplicationRecord
  belongs_to :product

  state_machine initial: :pending do
    event :submit do
      transition pending: :submitted
    end

    event :correct do
      transition submitted: :correcting
    end

    event :return do
      transition correcting: :returned
    end

    after_transition pending: :submitted do |exercise, _transition|
      # email the user to confirm
      # email the correctors
    end

    after_transition submitted: :correcting do |exercise, _transition|
      # no need to do anything here, just to show the other correctors that it
      # is in progress
    end

    after_transition correcting: :returned do |exercise, _transition|
      # email the user to say their corrections are available
    end
  end
end
