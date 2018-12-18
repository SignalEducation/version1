# == Schema Information
#
# Table name: course_sections
#
#  id                        :integer          not null, primary key
#  subject_course_id         :integer
#  name                      :string
#  name_url                  :string
#  sorting_order             :integer
#  active                    :boolean          default(FALSE)
#  counts_towards_completion :boolean          default(FALSE)
#  assumed_knowledge         :boolean          default(FALSE)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  cme_count                 :integer          default(0)
#  video_count               :integer          default(0)
#  quiz_count                :integer          default(0)
#  destroyed_at              :datetime
#

require 'rails_helper'

RSpec.describe CourseSectionController, type: :controller do

end
