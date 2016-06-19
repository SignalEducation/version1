# == Schema Information
#
# Table name: white_papers
#
#  id                       :integer          not null, primary key
#  title                    :string
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_file_name           :string
#  file_content_type        :string
#  file_file_size           :integer
#  file_updated_at          :datetime
#  sorting_order            :integer
#  cover_image_file_name    :string
#  cover_image_content_type :string
#  cover_image_file_size    :integer
#  cover_image_updated_at   :datetime
#  name_url                 :string
#

class WhitePaper < ActiveRecord::Base

  # attr-accessible
  attr_accessible :title, :description, :file, :cover_image, :sorting_order, :name_url

  # Constants

  # relationships
  has_many :white_paper_requests
  has_attached_file :file, default_url: '/assets/images/missing.png'
  has_attached_file :cover_image, default_url: '/assets/images/missing.png'

  # validation
  validates :title, presence: true, uniqueness: true
  validates :name_url, presence: true, uniqueness: true
  validates :description, presence: true
  validates_attachment_content_type :file,
                                    content_type: %w(application/pdf)
  validates_attachment_content_type :cover_image,
                                    content_type: /\Aimage\/.*\Z/

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :title) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
