# == Schema Information
#
# Table name: marketing_tokens
#
#  id                    :integer          not null, primary key
#  code                  :string
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
  SYSTEM_TOKEN_CODES = %w{seo direct}

  # relationships
  belongs_to :marketing_category
  has_many :user_activity_logs

  # validation
  validates :code, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A\w+\z/ }, length: { maximum: 255 }
  validates :marketing_category_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:code) }

  # class methods
  def self.direct_token
    return self.where(code: 'direct').first
  end

  def self.seo_token
    return self.where(code: 'seo').first
  end

  def self.parse_csv(csv_content)
    csv_data = []
    used_codes = []
    has_errors = false
    if csv_content.respond_to?(:each_line)
      csv_content.each_line do |line|
        line.strip.split(',').tap do |fields|
          error_msgs = []
          if fields.length == 3
            error_msgs << I18n.t('models.marketing_tokens.duplicated_token_code') if used_codes.include?(fields[0])
            error_msgs << I18n.t('models.marketing_tokens.invalid_marketing_category_name') if MarketingCategory.where(name: fields[1].strip).count != 1

            token = self.where(code: fields[0].strip).first
            error_msgs << I18n.t('models.marketing_tokens.cannot_change_system_token') if token && token.system_defined?
            error_msgs << I18n.t('models.marketing_tokens.invalid_flag_value') unless ['true', 'false'].include?(fields[2].strip)

            used_codes << fields[0]
          else
            error_msgs << I18n.t('models.marketing_tokens.invalid_field_count')
          end
          has_errors = true unless error_msgs.empty?
          csv_data << { values: fields, error_messages: error_msgs }
        end
      end
    else
      has_errors = true
    end
    has_errors = true if csv_data.empty?
    return csv_data, has_errors
  end

  def self.bulk_create(tokens_data)
    tokens = []
    used_codes = []
    if tokens_data.is_a?(Hash)
      self.transaction do
        tokens_data.each do |k,v|
          category = MarketingCategory.where(name: v['category']).first
          if category.nil? || v['code'].empty?
            tokens = []
            raise ActiveRecord::Rollback
          end

          token = self.where(code: v['code'], marketing_category_id: category.id).first_or_create

          if used_codes.include?(v['code']) || !token.valid? || !token.editable?
            tokens = []
            raise ActiveRecord::Rollback
          end
          token.update_attribute(:is_hard, v['flag'] == 'true')

          tokens << token
          used_codes << token.code
        end
      end
    end
    tokens
  end

  # instance methods
  def destroyable?
    !system_defined? && self.user_activity_logs.empty?
  end

  def editable?
    !system_defined?
  end

  def system_defined?
    SYSTEM_TOKEN_CODES.include?(self.code.to_s)
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
