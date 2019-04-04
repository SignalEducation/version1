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
#

require 'rails_helper'

RSpec.describe Exercise, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
