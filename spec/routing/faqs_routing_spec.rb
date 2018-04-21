# == Schema Information
#
# Table name: faqs
#
#  id              :integer          not null, primary key
#  name            :string
#  name_url        :string
#  active          :boolean          default(TRUE)
#  sorting_order   :integer
#  faq_section_id  :integer
#  question_text   :text
#  answer_text     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pre_answer_text :text
#

require 'rails_helper'

RSpec.describe FaqsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/faqs').to route_to('faqs#index')
    end

    it 'routes to #new' do
      expect(get: '/faqs/new').to route_to('faqs#new')
    end

    it 'routes to #show' do
      expect(get: '/faqs/1').to route_to('faqs#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/faqs/1/edit').to route_to('faqs#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/faqs').to route_to('faqs#create')
    end

    it 'routes to #update' do
      expect(put: '/faqs/1').to route_to('faqs#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/faqs/reorder').to route_to('faqs#reorder')
    end
    # todo move this to routes.rb ABOVE the resource:
    # post 'faqs/reorder', to: 'faqs#reorder'

    it 'routes to #destroy' do
      expect(delete: '/faqs/1').to route_to('faqs#destroy', id: '1')
    end

  end
end
