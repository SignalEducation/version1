require 'rails_helper'

RSpec.describe CoursesController, type: :routing do
  describe 'routing' do

    it 'routes to #create' do
      expect(post: '/courses').to route_to('courses#create')
    end

    # special routes - to courses#show

    it 'routes to #show' do
      expect(get: '/courses/subject_course/course_module/course_module_element').to route_to('courses#show', subject_course_name_url: 'subject_course', course_module_name_url: 'course_module', course_module_element_name_url: 'course_module_element')
    end
  end
end

RSpec.describe CoursesController, type: :request do

  # special routes - to courses#show

  it 'redirects to /library' do
    get '/en/courses/abc'
    expect(response).to redirect_to('/en/library/abc')
  end

  it 'redirects to /library' do
    get '/en/courses/abc/def'
    expect(response).to redirect_to('/en/library')
  end

  it 'redirects to /library' do
    get '/courses/abc/def'
    expect(response).to redirect_to('/en/library')
  end

  it 'redirects to /library' do
    get '/en/courses/abc/def/ghi'
    expect(response).to redirect_to('/en/library')
  end

  it 'redirects to /library' do
    get '/courses/abc/def/ghi'
    expect(response).to redirect_to('/en/library')
  end
end
