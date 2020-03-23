# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_introduction_pages
#
#  id            :bigint           not null, primary key
#  sorting_order :integer
#  content       :text
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cbe_id        :bigint
#  kind          :integer          default("0"), not null
#
class Cbe
  class IntroductionPage < ApplicationRecord
    enum kind: { text: 0, agreement: 1 }
    # relationships
    belongs_to :cbe

    # validations
    validates :title, :content, :cbe_id, presence: true
  end
end
