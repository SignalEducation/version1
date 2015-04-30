require 'rails_helper'

RSpec.describe CoursesController, type: :routing do
  describe 'routing' do

    it 'routes to #create' do
      expect(post: '/courses').to route_to('courses#create')
    end

    # special routes - to courses#show

    it 'routes to #show' do
      expect(get: '/courses/subject_area/institution/qualification/exam_level/exam_section/course_module').to route_to('courses#show', subject_area_name_url: 'subject_area', institution_name_url: 'institution', qualification_name_url: 'qualification', exam_level_name_url: 'exam_level', exam_section_name_url: 'exam_section', course_module_name_url: 'course_module')
    end

    it 'routes to #show' do
      expect(get: '/courses/subject_area/institution/qualification/exam_level/exam_section/course_module/course_module_element').to route_to('courses#show', subject_area_name_url: 'subject_area', institution_name_url: 'institution', qualification_name_url: 'qualification', exam_level_name_url: 'exam_level', exam_section_name_url: 'exam_section', course_module_name_url: 'course_module', course_module_element_name_url: 'course_module_element')
    end
  end
end

RSpec.describe CoursesController, type: :request do

  # special routes - to courses#show

  it 'redirects to /library' do
    get 'en/courses/abc'
    expect(response).to redirect_to('/en/library/abc')
  end

  it 'redirects to /library' do
    get '/courses/abc'
    expect(response).to redirect_to('/en/library/abc')
  end

  it 'redirects to /library' do
    get 'en/courses/abc/def'
    expect(response).to redirect_to('/en/library/abc/def')
  end

  it 'redirects to /library' do
    get '/courses/abc/def'
    expect(response).to redirect_to('/en/library/abc/def')
  end

  it 'redirects to /library' do
    get 'en/courses/abc/def/ghi'
    expect(response).to redirect_to('/en/library/abc/def/ghi')
  end

  it 'redirects to /library' do
    get '/courses/abc/def/ghi'
    expect(response).to redirect_to('/en/library/abc/def/ghi')
  end

  it 'redirects to /library' do
    get 'en/courses/abc/def/ghi/jkl'
    expect(response).to redirect_to('/en/library/abc/def/ghi/jkl')
  end

  it 'redirects to /library' do
    get '/courses/abc/def/ghi/jkl'
    expect(response).to redirect_to('/en/library/abc/def/ghi/jkl')
  end

  it 'redirects to /library' do
    get 'en/courses/abc/def/ghi/jkl/mno'
    expect(response).to redirect_to('/en/library/abc/def/ghi/jkl/mno')
  end

  it 'redirects to /library' do
    get '/courses/abc/def/ghi/jkl/mno'
    expect(response).to redirect_to('/en/library/abc/def/ghi/jkl/mno')
  end
end
