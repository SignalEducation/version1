# == Schema Information
#
# Table name: exercises
#
#  id           :bigint(8)        not null, primary key
#  product_id   :bigint(8)
#  state        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint(8)
#  corrector_id :bigint(8)
#

require 'rails_helper'

RSpec.describe Exercise, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
