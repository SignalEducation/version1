# == Schema Information
#
# Table name: course_module_elements
#
#  id                        :integer          not null, primary key
#  name                      :string
#  name_url                  :string
#  description               :text
#  estimated_time_in_seconds :integer
#  course_module_id          :integer
#  sorting_order             :integer
#  tutor_id                  :integer
#  related_quiz_id           :integer
#  related_video_id          :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default(FALSE), not null
#  is_quiz                   :boolean          default(FALSE), not null
#  active                    :boolean          default(TRUE), not null
#  is_cme_flash_card_pack    :boolean          default(FALSE), not null
#  seo_description           :string
#  seo_no_index              :boolean          default(FALSE)
#  destroyed_at              :datetime
#  number_of_questions       :integer          default(0)
#  duration                  :float            default(0.0)
#

require 'rails_helper'

RSpec.describe CourseModuleElementsController, type: :routing do
  describe 'routing' do

    it 'routes to #show' do
      expect(get: '/course_module_elements/1').to route_to('course_module_elements#show', id: '1')
    end

    it 'routes to #new' do
      expect(get: '/course_module_elements/new').to route_to('course_module_elements#new')
    end

    it 'routes to #edit' do
      expect(get: '/course_module_elements/1/edit').to route_to('course_module_elements#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/course_module_elements').to route_to('course_module_elements#create')
    end

    it 'routes to #update' do
      expect(put: '/course_module_elements/1').to route_to('course_module_elements#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/course_module_elements/reorder').to route_to('course_module_elements#reorder')
    end

    it 'routes to #destroy' do
      expect(delete: '/course_module_elements/1').to route_to('course_module_elements#destroy', id: '1')
    end

  end
end
