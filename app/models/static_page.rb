class StaticPage < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :publish_from, :publish_to, :allow_multiples, :public_url, :use_standard_page_template, :head_content, :body_content, :created_by, :updated_by, :add_to_navbar, :add_to_footer, :menu_label, :tooltip_text, :language, :mark_as_noindex, :mark_as_nofollow, :seo_title, :seo_description, :approved_country_ids, :default_page_for_this_url, :make_this_page_sticky

  # Constants

  # relationships

  # validation
  validates :name, presence: true
  validates :publish_from, presence: true
  validates :publish_to, presence: true
  validates :public_url, presence: true
  validates :head_content, presence: true
  validates :body_content, presence: true
  validates :created_by, presence: true
  validates :updated_by, presence: true
  validates :menu_label, presence: true
  validates :tooltip_text, presence: true
  validates :language, presence: true
  validates :seo_title, presence: true
  validates :seo_description, presence: true
  validates :approved_country_ids, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
