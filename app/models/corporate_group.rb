class CorporateGroup < ActiveRecord::Base

  # attr-accessible
  attr_accessible :corporate_customer_id, :name

  # Constants

  # relationships
  belongs_to :corporate_customer
  has_and_belongs_to_many :users
  has_many :corporate_group_grants

  # validation
  validates :corporate_customer_id, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :name, presence: true,
            uniqueness: { scope: :corporate_customer_id }

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:corporate_customer_id) }

  # class methods

  # instance methods
  def destroyable?
    corporate_group_grants.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
