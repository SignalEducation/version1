# == Schema Information
#
# Table name: subject_areas
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  name_url      :string(255)
#  sorting_order :integer
#  active        :boolean          default(FALSE), not null
#  created_at    :datetime
#  updated_at    :datetime
#

class SubjectArea < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :name_url, :sorting_order, :active

  # Constants

  # relationships
  has_many :institutions

  # validation
  validates :name, presence: true, uniqueness: true
  validates :name_url, presence: true, uniqueness: true
  validates :sorting_order, presence: true, numericality: true

  # callbacks
  before_save :sanitize_name_url
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_active, -> { where(active: true) }
  scope :all_inactive, -> { where(active: false) }

  # class methods

  # instance methods
  def destroyable?
    !self.active && self.institutions.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def sanitize_name_url
    self.name_url = self.name_url.to_s.gsub(' ', '-').gsub('/', '-').gsub('.', '-').gsub('_', '-').gsub('&', '-').gsub('?', '-').gsub('=', '-').gsub(':', '-').gsub(';', '-')
  end

end
