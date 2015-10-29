# == Schema Information
#
# Table name: users
#
#  id                                       :integer          not null, primary key
#  email                                    :string
#  first_name                               :string
#  last_name                                :string
#  address                                  :text
#  country_id                               :integer
#  crypted_password                         :string(128)      default(""), not null
#  password_salt                            :string(128)      default(""), not null
#  persistence_token                        :string
#  perishable_token                         :string(128)
#  single_access_token                      :string
#  login_count                              :integer          default(0)
#  failed_login_count                       :integer          default(0)
#  last_request_at                          :datetime
#  current_login_at                         :datetime
#  last_login_at                            :datetime
#  current_login_ip                         :string
#  last_login_ip                            :string
#  account_activation_code                  :string
#  account_activated_at                     :datetime
#  active                                   :boolean          default(FALSE), not null
#  user_group_id                            :integer
#  password_reset_requested_at              :datetime
#  password_reset_token                     :string
#  password_reset_at                        :datetime
#  stripe_customer_id                       :string
#  corporate_customer_id                    :integer
#  operational_email_frequency              :string
#  study_plan_notifications_email_frequency :string
#  falling_behind_email_alert_frequency     :string
#  marketing_email_frequency                :string
#  marketing_email_permission_given_at      :datetime
#  blog_notification_email_frequency        :string
#  forum_notification_email_frequency       :string
#  created_at                               :datetime
#  updated_at                               :datetime
#  locale                                   :string
#  guid                                     :string
#  trial_ended_notification_sent_at         :datetime
#  crush_offers_session_id                  :string
#  subscription_plan_category_id            :integer
#  employee_guid                            :string
#  password_change_required                 :boolean
#  session_key                              :string
#  first_description                        :text
#  second_description                       :text
#  wistia_url                               :text
#  personal_url                             :text
#  name_url                                 :string
#  qualifications                           :text
#  profile_image_file_name                  :string
#  profile_image_content_type               :string
#  profile_image_file_size                  :integer
#  profile_image_updated_at                 :datetime
#

class User < ActiveRecord::Base

  include LearnSignalModelExtras

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  # attr-accessible
  attr_accessible :email, :first_name, :last_name, :active,
                  :country_id, :user_group_id, :password_reset_requested_at,
                  :password_reset_token, :password_reset_at, :stripe_customer_id,
                  :corporate_customer_id, :password,
                  :password_confirmation, :current_password, :locale,
                  :subscriptions_attributes, :employee_guid, :password_change_required,
                  :address, :first_description, :second_description, :wistia_url, :personal_url,
                  :name_url, :qualifications, :profile_image, :account_activated_at, :account_activation_code

  # Constants
  EMAIL_FREQUENCIES = %w(off daily weekly monthly)
  LOCALES = %w(en)
  SORT_OPTIONS = %w(created user_group name email)

  # relationships
  belongs_to :corporate_customer
             # employed by the corporate customer
  belongs_to :country
  has_many :course_modules, foreign_key: :tutor_id
  has_many :course_module_element_user_logs
  has_many :subject_courses, foreign_key: :tutor_id
  has_many :invoices
  has_many :quiz_attempts
  has_many :question_banks
  has_many :created_static_pages, class_name: 'StaticPage', foreign_key: :created_by
  has_many :updated_static_pages, class_name: 'StaticPage', foreign_key: :updated_by
  has_many :subscriptions, -> { order(:id) }, inverse_of: :user
  has_many :subscription_payment_cards
  has_many :subscription_transactions
  has_many :student_exam_tracks
  has_many :user_activity_logs
  belongs_to :user_group
  has_many :user_notifications
  has_one :referral_code
  has_one :referred_signup
  belongs_to :subscription_plan_category
  has_and_belongs_to_many :corporate_groups
  has_attached_file :profile_image, default_url: '/assets/images/missing_corporate_logo.png'

  accepts_nested_attributes_for :subscriptions

  # validation
  validates :email, presence: true, uniqueness: true,
            length: {within: 7..40}
            #TODO
            #format: {with:  /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i,
            #         message: 'must be a valid email address.'}
  validates :first_name, presence: true, length: {minimum: 2, maximum: 20}
  validates :last_name, presence: true, length: {minimum: 2, maximum: 30}
  validates :password, presence: true, length: {minimum: 6, maximum: 255}, on: :create
  validates_confirmation_of :password, on: :create
  validates_confirmation_of :password, if: '!password.blank?'
  validates :country_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_group_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :corporate_customer_id,
            numericality: { unless: -> { corporate_customer_id.nil? }, only_integer: true, greater_than: 0 },
            presence: { if: -> { ug = UserGroup.find_by_id(user_group_id); ug.try(:corporate_customer) || ug.try(:corporate_student) } }
  validates :locale, inclusion: {in: LOCALES}
  #validates :employee_guid, allow_nil: true,
  #          uniqueness: { scope: :corporate_customer_id }
  validates_attachment_content_type :profile_image, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_validation :set_defaults, on: :create
  before_validation { squish_fields(:email, :first_name, :last_name) }
  # before_validation :de_activate_user, on: :create, if: '!Rails.env.test?'
  before_create :add_guid
  after_create :set_stripe_customer_id

  # scopes
  scope :all_in_order, -> { order(:user_group_id, :last_name, :first_name, :email) }
  scope :search_for, lambda { |search_term| where("email ILIKE :t OR first_name ILIKE :t OR last_name ILIKE :t OR textcat(first_name, textcat(text(' '), last_name)) ILIKE :t", t: '%' + search_term + '%') }
  scope :sort_by_email, -> { order(:email) }
  scope :sort_by_name, -> { order(:last_name, :first_name) }
  scope :sort_by_recent_registration, -> { order(created_at: :desc) }

  # class methods
  def self.all_admins
    includes(:user_group).references(:user_groups).where('user_groups.site_admin = ?', true)
  end

  def self.all_tutors
    includes(:user_group).references(:user_groups).where('user_groups.tutor = ?', true)
  end

  def self.get_and_activate(activation_code)
    user = User.where.not(active: true).where(account_activation_code: activation_code, account_activated_at: nil).first
    if user
      user.account_activated_at = Proc.new{Time.now}.call
      user.account_activation_code = nil
      user.active = true
      user.save!
    end
    return user
  end

  def self.start_password_reset_process(the_email_address, root_url)
    if the_email_address.to_s.length > 5 # a@b.co
      user = User.where(email: the_email_address.to_s).first
      if user
        user.update_attributes(
                password_reset_requested_at: Proc.new{Time.now}.call,
                password_reset_token: ApplicationController::generate_random_code(20),
                active: false)
        MandrillWorker.perform_async(user.id, 'send_password_reset_email', "#{root_url}/reset_password/#{user.password_reset_token}")
      end
    end
  end

  def self.finish_password_reset_process(reset_token, new_password,
          new_password_confirmation)
    if reset_token.to_s.length == 20 && new_password.to_s.length > 5 && new_password_confirmation.to_s.length > 5 && new_password.to_s == new_password_confirmation.to_s
      user = User.where(password_reset_token: reset_token.to_s, active: false).first
      if user
        if user.update_attributes(password: new_password.to_s,
                                  password_confirmation: new_password_confirmation.to_s,
                                  active: true, password_reset_token: nil,
                                  password_reset_requested_at: nil,
                                  password_reset_at: Time.now)
          user # return this
        else
          false
        end
      else
        false
      end
    else
      false # return false
    end
  end

  def self.sort_by(choice)
    if SORT_OPTIONS.include?(choice)
      case choice
        when 'name'
          sort_by_name
        when 'email'
          sort_by_email
        when 'created'
          sort_by_recent_registration
        else # also covers 'user_group'
          all_in_order
      end
    else
      all_in_order
    end
  end

  # instance methods
  def admin?
    self.user_group.try(:site_admin)
  end

  def assign_anonymous_logs_to_user(session_guid)
    model_list = [CourseModuleElementUserLog, UserActivityLog, StudentExamTrack, SubjectCourseUserLog]
    model_list.each do |the_model|
      the_model.assign_user_to_session_guid(self.id, session_guid)
    end
  end

  def change_the_password(options)
    # options = {current_password: '123123123', password: 'new123',
    #            password_confirmation: 'new123'}
    if options[:password] == options[:password_confirmation] &&
            options[:password].to_s != '' &&
            self.valid_password?(options[:current_password].to_s) &&
            options[:current_password].to_s != ''
      self.update_attributes(
              password: options[:password],
              password_confirmation: options[:password_confirmation]
      )
    else
      false
    end
  end

  def blogger?
    self.user_group.try(:blogger)
  end

  def content_manager?
    self.user_group.try(:content_manager)
  end

  def corporate_customer?
    self.user_group.try(:corporate_customer)
  end

  def corporate_student?
    self.user_group.try(:corporate_student)
  end

  def corporate_tutor?
    self.user_group.try(:corporate_tutor) && !self.user_group.try(:corporate_customer)
  end

  def de_activate_user
    self.active = false
    self.account_activated_at = nil
    self.account_activation_code = ApplicationController::generate_random_code(20)
  end

  def destroyable?
    !self.admin? &&
        self.course_modules.empty? &&
        self.course_module_element_user_logs.empty? &&
        self.invoices.empty? &&
        self.quiz_attempts.empty? &&
        self.student_exam_tracks.empty? &&
        self.subscriptions.empty? &&
        self.subscription_payment_cards.empty? &&
        self.subscription_transactions.empty? &&
        self.user_notifications.empty? &&
        self.created_static_pages.empty? &&
        self.updated_static_pages.empty? &&
        self.user_activity_logs.empty?
  end

  def full_name
    self.first_name.titleize + ' ' + self.last_name.gsub('O\'','O\' ').titleize.gsub('O\' ','O\'')
  end

  def individual_student?
    self.user_group.try(:individual_student) && self.corporate_customer_id.to_i == 0
  end

  def tutor?
    self.user_group.try(:tutor)
  end

  def set_original_mixpanel_alias_id(mixpanel_alias_id)
    @mixpanel_alias_id = mixpanel_alias_id
  end

  #Corporate Account Methods

  def compulsory_group_ids
    @compulsory_group_ids ||=
      corporate_student? ? corporate_groups.map { |cg| cg.compulsory_group_ids }.flatten.uniq : []
  end

  def restricted_group_ids
    @restricted_group_ids ||=
      corporate_student? ?
        (corporate_groups.map { |cg| cg.restricted_group_ids }.flatten.uniq - compulsory_group_ids) : []
  end

  def compulsory_subject_course_ids
    @compulsory_subject_course_ids ||=
      corporate_student? ? corporate_groups.map { |cg| cg.compulsory_subject_course_ids }.flatten.uniq : []
  end

  def restricted_subject_course_ids
    @restricted_subject_course_ids ||=
      corporate_student? ?
        (corporate_groups.map { |cg| cg.restricted_subject_course_ids }.flatten.uniq - compulsory_subject_course_ids) : []
  end

  def self.parse_csv(csv_content)
    csv_data = []
    duplicate_emails = []
    has_errors = false
    if csv_content.respond_to?(:each_line)
      csv_content.each_line do |line|
        line.strip.split(',').tap do |fields|
          error_msgs = []
          if fields.length == 3
            error_msgs << I18n.t('models.users.duplicated_emails') if duplicate_emails.include?(fields[0])
            error_msgs << I18n.t('models.users.existing_emails') if User.where(email: fields[0].strip).count > 0
            error_msgs << I18n.t('models.users.not_valid_email') unless fields[0].include?('@')

            duplicate_emails << fields[0]
          else
            error_msgs << I18n.t('models.users.invalid_field_count')
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

  def self.bulk_create(csv_data, corporate_manager)
    users = []
    used_emails = []
    if csv_data.is_a?(Hash)
      self.transaction do
        csv_data.each do |k,v|
          user = User.where(email: v['email']).first
          if user || v['email'].empty?
            users = []
            raise ActiveRecord::Rollback
          end
          password = SecureRandom.hex(5)

          user = self.where(email: v['email'], first_name: v['first_name'], last_name: v['last_name']).first_or_create
          user.update_attributes(password: password, password_confirmation: password, user_group_id: UserGroup.where(corporate_student: true).first.id, country_id: corporate_manager.country_id, password_change_required: true, corporate_customer_id: corporate_manager.corporate_customer_id, locale: 'en', active: false, account_activated_at: nil, account_activation_code: ApplicationController::generate_random_code(20))

          if used_emails.include?(v['email']) || !user.valid?
            users = []
            raise ActiveRecord::Rollback
          end
          users << user
          used_emails << user.email
        end
      end
    end
    users
  end

  protected

  def add_guid
    self.guid ||= ApplicationController.generate_random_code(10)
    Rails.logger.debug "DEBUG: User#add_guid - FINISH at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}"
  end

  def set_defaults
    Rails.logger.debug "DEBUG: User#set_defaults - START at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}"
    self.marketing_email_permission_given_at ||= Proc.new{Time.now}.call
    self.operational_email_frequency ||= 'weekly'
    self.study_plan_notifications_email_frequency ||= 'off'
    self.falling_behind_email_alert_frequency ||= 'off'
    self.marketing_email_frequency ||= 'off'
    self.blog_notification_email_frequency ||= 'off'
    self.forum_notification_email_frequency ||= 'off'
    Rails.logger.debug "DEBUG: User#set_defaults - FINISH at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}}"
  end

  def set_stripe_customer_id
    Rails.logger.debug "DEBUG: User#set_stripe_customer_id - START at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}}"
    if self.subscriptions.length > 0
      self.update_attribute(:stripe_customer_id, self.subscriptions.first.stripe_customer_id)
    end
    Rails.logger.debug "DEBUG: User#set_stripe_customer_id - FINISH at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}}"
  end

end
