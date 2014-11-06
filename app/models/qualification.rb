# == Schema Information
#
# Table name: qualifications
#
#  id                          :integer          not null, primary key
#  institution_id              :integer
#  name                        :string(255)
#  name_url                    :string(255)
#  sorting_order               :integer
#  active                      :boolean          default(FALSE), not null
#  cpd_hours_required_per_year :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#

class Qualification < ActiveRecord::Base

  # attr-accessible
  attr_accessible :institution_id, :name, :name_url, :sorting_order, :active, :cpd_hours_required_per_year

  # Constants

  # relationships
  has_many :course_modules
  has_many :exam_levels
  belongs_to :institution

  # validation
  validates :institution_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :name_url, presence: true,uniqueness: true
  validates :sorting_order, presence: true
  validates :cpd_hours_required_per_year, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:institution_id, :sorting_order) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first # MAY return a 'nil'
  end

  # instance methods
  def destroyable?
    self.exam_levels.empty? && self.course_modules.empty?
  end

  def full_name
    self.institution.name + ' > ' + self.name
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
