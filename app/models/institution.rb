# == Schema Information
#
# Table name: institutions
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  short_name             :string(255)
#  name_url               :string(255)
#  description            :text
#  feedback_url           :string(255)
#  help_desk_url          :string(255)
#  subject_area_id        :integer
#  sorting_order          :integer
#  active                 :boolean          default(FALSE), not null
#  created_at             :datetime
#  updated_at             :datetime
#  background_colour_code :string(255)
#  seo_description        :string(255)
#  seo_no_index           :boolean          default(FALSE)
#

class Institution < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :short_name, :name_url, :description,
                  :feedback_url, :help_desk_url, :subject_area_id,
                  :sorting_order, :active, :background_colour_code,
                  :seo_description, :seo_no_index

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
  validates :seo_description, presence: true
  validates :sorting_order, presence: true

  # callbacks
  before_validation { squish_fields(:name, :short_name, :name_url, :description, :feedback_url, :help_desk_url) }
  before_create :set_sorting_order
  before_save :sanitize_name_url

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_in_order, -> { order(:sorting_order, :name) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first # MAY return a 'nil'
  end

  # instance methods
  def active_children
    self.children.all_active
  end

  def children
    self.qualifications.all
  end

  def destroyable?
    !self.active && self.qualifications.empty? && self.institution_users.empty? && self.course_modules.empty?
  end

  def full_name
    self.subject_area.name + ' > ' + self.name
  end

  def parent
    self.subject_area
  end

  def text_colour_class
    number = 0 # default value
    if self.background_colour_code.to_s.size == 6
      little_array = [self.background_colour_code[0..1], self.background_colour_code[2..3], self.background_colour_code[4..5]]
      number = little_array[0].to_i(16) + little_array[1].to_i(16) + little_array[2].to_i(16) # gives us a decimal number between 0 and 765 (=255x3)
    end
    number > 500 ? 'text-dark' : 'text-light'
  end

  protected

end
