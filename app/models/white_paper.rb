# == Schema Information
#
# Table name: white_papers
#
#  id                :integer          not null, primary key
#  title             :string
#  description       :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  sorting_order     :integer
#

class WhitePaper < ActiveRecord::Base

  # attr-accessible
  attr_accessible :title, :description, :file

  # Constants

  # relationships
  has_attached_file :file

  # validation
  validates :title, presence: true
  validates :description, presence: true
  validates_attachment_content_type :file,
                                    content_type: %w(application/pdf)

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:title) }

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
