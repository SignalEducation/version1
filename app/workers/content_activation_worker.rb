class ContentActivationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(type, id)
    if type == 'CourseModuleElement'
      course_module_element = CourseModuleElement.find(id)
      course_module_element.update_attributes(active: true) if course_module_element.valid?
    elsif type == 'SubjectCourseResource'
      subject_course_resource = SubjectCourseResource.find(id)
      subject_course_resource.update_attributes(active: true) if subject_course_resource.valid?
    elsif type == 'ContentPage'
      content_page = ContentPage.find(id)
      content_page.update_attributes(active: true) if content_page.valid?
    elsif type == 'HomePage'
      home_page = HomePage.find(id)
      home_page.update_attributes(active: true) if home_page.valid?
    else

    end

  end

end
