# == Schema Information
#
# Table name: raw_video_files
#
#  id                             :integer          not null, primary key
#  file_name                      :string(255)
#  course_module_element_video_id :integer
#  transcode_requested            :boolean          default(FALSE), not null
#  created_at                     :datetime
#  updated_at                     :datetime
#

class RawVideoFile < ActiveRecord::Base

  # attr-accessible
  attr_accessible :file_name, :course_module_element_video_id, :transcode_requested

  # Constants

  # relationships
  belongs_to :course_module_element_video

  # validation
  validates :file_name, presence: true
  validates :course_module_element_video_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:file_name) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  def assign_me_to_cme_video(the_id)
    # todo self.course_module_element_video_id = the_id
    trigger_transcode(the_id)
  end

  def trigger_transcode(the_id)
    # todo AWS::ElasticTranscode(source: self.file_name, folder: "/#{Rails.env}/#{the_id}/")
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
