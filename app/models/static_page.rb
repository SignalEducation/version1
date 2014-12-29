# == Schema Information
#
# Table name: static_pages
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  publish_from               :datetime
#  publish_to                 :datetime
#  allow_multiples            :boolean          default(FALSE), not null
#  public_url                 :string(255)
#  use_standard_page_template :boolean          default(FALSE), not null
#  head_content               :text
#  body_content               :text
#  created_by                 :integer
#  updated_by                 :integer
#  add_to_navbar              :boolean          default(FALSE), not null
#  add_to_footer              :boolean          default(FALSE), not null
#  menu_label                 :string(255)
#  tooltip_text               :string(255)
#  language                   :string(255)
#  mark_as_noindex            :boolean          default(FALSE), not null
#  mark_as_nofollow           :boolean          default(FALSE), not null
#  seo_title                  :string(255)
#  seo_description            :string(255)
#  approved_country_ids       :text
#  default_page_for_this_url  :boolean          default(FALSE), not null
#  make_this_page_sticky      :boolean          default(FALSE), not null
#  logged_in_required         :boolean          default(FALSE), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#

# todo make_this_page_sticky
# todo approved_country_ids

class StaticPage < ActiveRecord::Base

  serialize :approved_country_ids, Array

  # attr-accessible
  attr_accessible :name, :publish_from, :publish_to, :allow_multiples, :public_url, :use_standard_page_template, :head_content, :body_content, :created_by, :updated_by, :add_to_navbar, :add_to_footer, :menu_label, :tooltip_text, :language, :mark_as_noindex, :mark_as_nofollow, :seo_title, :seo_description, :approved_country_ids, :default_page_for_this_url, :make_this_page_sticky, :logged_in_required, :static_page_uploads_attributes

  # Constants

  # relationships
  belongs_to :creator, class_name: 'User', foreign_key: :created_by
  belongs_to :updater, class_name: 'User', foreign_key: :updated_by
  has_many :static_page_uploads, inverse_of: :static_page

  accepts_nested_attributes_for :static_page_uploads

  # validation
  validates :name, presence: true
  validates :publish_from, presence: true
  validates :public_url, presence: true, uniqueness: true, if: 'allow_multiples == false'
  validates :head_content, presence: true, unless: 'use_standard_page_template == true'
  validates :body_content, presence: true
  validates :created_by, presence: true
  validates :updated_by, presence: true, on: :update
  validates :menu_label, presence: true,
            if: 'add_to_navbar == true || add_to_footer == true'
  validates :tooltip_text, presence: true,
            if: 'add_to_navbar == true || add_to_footer == true'
  validates :language, presence: true
  validates :seo_title, presence: true
  validates :seo_description, presence: true

  # callbacks
  before_save :sanitize_public_url
  before_save :sanitize_country_ids
  after_save :update_default_for_related_pages
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:public_url, default_page_for_this_url: :desc) }
  scope :all_active, -> { where('publish_from < :now AND (publish_to IS NULL OR publish_to > :now)', {now: Proc.new{Time.now}.call} ) }
  scope :all_for_language, lambda { |lang| where(language: (lang || 'en')) }
  scope :all_for_country, lambda { |country_id| where("approved_country_ids = '[]' OR approved_country_ids LIKE '%?%'", country_id) }

  # class methods
  def self.all_of_type(the_type)
    if the_type == 'navbar'
      where(add_to_navbar: true)
    elsif the_type == 'footer'
      where(add_to_footer: true)
    end
  end

  def self.with_logged_in_status(the_status)
    if the_status
      all
    else
      where(logged_in_required: false)
    end
  end

  # instance methods
  def destroyable?
    !(self.publish_from < Proc.new{Time.now}.call && (self.publish_to == nil || self.publish_to > Proc.new{Time.now}.call))
  end

  protected

  def check_dependencies
    if self.destroyable?
      self.static_page_uploads.destroy_all
    else
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def sanitize_country_ids
    old_list = self.approved_country_ids.dup
    self.approved_country_ids = []
    old_list.each do |item|
      self.approved_country_ids << item.to_i if item.to_i > 0
    end
  end

  def sanitize_public_url
    if self.public_url[0] == '/'
      self.public_url = self.public_url[1.. -1]
    end
    self.public_url = self.public_url.to_s.gsub(' ', '-').gsub('/', '-').gsub('.', '-').gsub('_', '-').gsub('&', '-').gsub('?', '-').gsub('=', '-').gsub(':', '-').gsub(';', '-')
    self.public_url = '/' + self.public_url
  end

  def update_default_for_related_pages
    if self.allow_multiples && self.default_page_for_this_url
      others = StaticPage.where(public_url: self.public_url).where.not(id: self.id)
      others.update_all(default_page_for_this_url: false)
    end
  end

end
