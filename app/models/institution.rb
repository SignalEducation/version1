# == Schema Information
#
# Table name: institutions
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  short_name      :string(255)
#  name_url        :string(255)
#  description     :text
#  feedback_url    :string(255)
#  help_desk_url   :string(255)
#  subject_area_id :integer
#  sorting_order   :integer
#  active          :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#

class Institution < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :short_name, :name_url, :description,
                  :feedback_url, :help_desk_url, :subject_area_id,
                  :sorting_order, :active

  # Constants

  # relationships
  has_many :course_modules
  has_many :institution_users
  has_many :qualifications
  belongs_to :subject_area

  # validation
  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true, uniqueness: true
  validates :name_url, presence: true
  validates :description, presence: true
  validates :feedback_url, presence: true
  validates :help_desk_url, presence: true
  validates :subject_area_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true

  # callbacks
  before_validation { squish_fields(:name, :short_name, :name_url, :description, :feedback_url, :help_desk_url) }
  before_save :sanitize_name_url

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_in_order, -> { order(:sorting_order, :name) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first # MAY return a 'nil'
  end

  # instance methods
  def children
    self.qualifications.all
  end

  def destroyable?
    !self.active && self.qualifications.empty? && self.institution_users.empty? && self.course_modules.empty?
  end

  def full_name
    self.subject_area.name + ' > ' + self.name
  end

  protected

end
