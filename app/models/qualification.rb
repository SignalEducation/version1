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
#  seo_description             :string(255)
#  seo_no_index                :boolean          default(FALSE)
#

class Qualification < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :institution_id, :name, :name_url, :sorting_order, :active,:cpd_hours_required_per_year, :seo_description, :seo_no_index

  # Constants

  # relationships
  has_many :course_modules
  has_many :exam_levels
  belongs_to :institution

  # validation
  validates :institution_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :name_url, presence: true, uniqueness: true
  validates :sorting_order, presence: true
  validates :cpd_hours_required_per_year, presence: true
  validates :seo_description, presence: true

  # callbacks
  before_validation { squish_fields(:name, :name_url) }
  before_create :set_sorting_order
  before_save :sanitize_name_url

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_in_order, -> { order(:institution_id, :sorting_order) }
  scope :with_url, lambda { |the_url| where(name_url: the_url) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first # MAY return a 'nil'
  end

  # instance methods
  def active_children
    self.children.all_active
  end

  def children
    self.exam_levels.all
  end

  def destroyable?
    !self.active && self.exam_levels.empty? && self.course_modules.empty?
  end

  def full_name
    self.institution.name + ' > ' + self.name
  end

  def parent
    self.institution
  end

  protected

end
