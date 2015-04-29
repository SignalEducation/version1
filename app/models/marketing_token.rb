# == Schema Information
#
# Table name: marketing_tokens
#
#  id                    :integer          not null, primary key
#  code                  :string(255)
#  marketing_category_id :integer
#  is_hard               :boolean          default(FALSE), not null
#  is_direct             :boolean          default(FALSE), not null
#  is_seo                :boolean          default(FALSE), not null
#  created_at            :datetime
#  updated_at            :datetime
#

class MarketingToken < ActiveRecord::Base

  # attr-accessible
  attr_accessible :code, :marketing_category_id, :is_hard

  # Constants

  # relationships
  belongs_to :marketing_category

  # validation
  validates :code, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\w+/ }
  validates :marketing_category_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:code) }

  # class methods
  def self.import(csv_content)
    return unless csv_content.respond_to?(:each_line)
    csv_content.each_line do |line|
      line.split(',').tap do |fields|
        if fields.length == 3
          category = MarketingCategory.where(name: fields[1].strip).first
          token = self.where(code: fields[0].strip, marketing_category_id: category.id).first_or_create if category
          token.update_attribute(:is_hard, fields[2].strip == "true") if token && token.valid? && token.editable?
        end
      end
    end
  end

  # instance methods
  def destroyable?
    !system_defined?
  end

  def editable?
    !system_defined?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def system_defined?
    ['seo', 'direct'].include?(self.code.to_s)
  end

end
