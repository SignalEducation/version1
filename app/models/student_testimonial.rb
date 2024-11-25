# frozen_string_literal: true

# == Schema Information
#
# Table name: student_testimonials
#
#  id                 :bigint           not null, primary key
#  home_page_id       :integer
#  sorting_order      :integer
#  text               :text
#  signature          :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :bigint
#  image_updated_at   :datetime
#

class StudentTestimonial < ApplicationRecord
  # Constants

  # relationships
  belongs_to :home_page
  has_attached_file :image, default_url: 'images/missing_image.jpg'

  # validation
  validates :home_page_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :text, presence: true
  validates :signature, presence: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :home_page_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

end
