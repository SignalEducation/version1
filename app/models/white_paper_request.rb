# == Schema Information
#
# Table name: white_paper_requests
#
#  id             :integer          not null, primary key
#  name           :string
#  email          :string
#  number         :string
#  web_url        :string
#  company_name   :string
#  white_paper_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class WhitePaperRequest < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :email, :number, :web_url, :company_name, :white_paper_id

  # Constants

  # relationships
  belongs_to :white_paper

  # validation
  validates :name, presence: true
  validates :email, presence: true, length: {within: 7..40}
  validates :number, presence: true
  validates :web_url, presence: true
  validates :company_name, presence: true
  validates :white_paper_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }

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
