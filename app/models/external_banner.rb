# == Schema Information
#
# Table name: external_banners
#
#  id                 :integer          not null, primary key
#  name               :string
#  sorting_order      :integer
#  active             :boolean          default(FALSE)
#  background_colour  :string
#  text_content       :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_sessions      :boolean          default(FALSE)
#  library            :boolean          default(FALSE)
#  subscription_plans :boolean          default(FALSE)
#  footer_pages       :boolean          default(FALSE)
#  student_sign_ups   :boolean          default(FALSE)
#  home_page_id       :integer
#  content_page_id    :integer
#

class ExternalBanner < ActiveRecord::Base

  # Constants
  BANNER_CONTROLLERS = %w(user_sessions library subscription_plans footer_pages student_sign_ups)

  # relationships
  belongs_to :content_page
  belongs_to :home_page

  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :sorting_order, presence: true,
            numericality: {only_integer: true}
  validates :background_colour, presence: true
  validates :text_content, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_without_parent, -> { where(home_page_id: nil, content_page_id: nil) }
  scope :for_home_page, -> { where.not(home_page_id: nil) }
  scope :for_content_page, -> { where.not(content_page_id: nil) }
  scope :render_for, lambda { |controller_name| where("#{controller_name}" => true, 'active' => true) }

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
