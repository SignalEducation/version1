# == Schema Information
#
# Table name: blog_posts
#
#  id                 :integer          not null, primary key
#  home_page_id       :integer
#  sorting_order      :integer
#  title              :string
#  description        :text
#  url                :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#

class BlogPost < ActiveRecord::Base

  # attr-accessible
  attr_accessible :home_page_id, :sorting_order, :title, :description, :url,
                  :_destroy, :image

  # Constants

  # relationships
  belongs_to :home_page
  has_attached_file :image, default_url: "images/home_explore2.jpg"

  # validation
  validates :home_page_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :title, presence: true
  validates :description, presence: true
  validates :url, presence: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :home_page_id) }

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
