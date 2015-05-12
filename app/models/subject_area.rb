# == Schema Information
#
# Table name: subject_areas
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  name_url        :string(255)
#  sorting_order   :integer
#  active          :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#  seo_description :string(255)
#  seo_no_index    :boolean          default(FALSE)
#

class SubjectArea < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :name_url, :sorting_order, :active, :seo_description, :seo_no_index

  # Constants

  # relationships
  has_many :institutions

  # validation
  validates :name, presence: true, uniqueness: true
  validates :name_url, presence: true, uniqueness: true
  validates :sorting_order, presence: true, numericality: true
  validates :seo_description, presence: true

  # callbacks
  before_validation { squish_fields(:name, :name_url, :seo_description) }
  before_create :set_sorting_order
  before_save :sanitize_name_url

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_active, -> { where(active: true) }
  scope :all_inactive, -> { where(active: false) }

  # class methods

  # instance methods
  def children
    self.institutions.all
  end

  def active_children
    self.institutions.all_active
  end

  def destroyable?
    !self.active && self.institutions.empty?
  end

  def parent
    nil
  end

  protected

  def set_sorting_order
    self.sorting_order = SubjectArea.all.maximum(:sorting_order).to_i + 1
  end

end
