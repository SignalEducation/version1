# frozen_string_literal: true

module CoursesHelper
  def course_lesson_status(course_lesson, exam_tracks, completed_ids)
    exam_tracks && completed_ids.include?(course_lesson.id) ? 'completed' : ''
  end

  def course_element_user_log_status(log)
    return '' if log.nil?

    log.is_quiz? ? quiz_status(log) : course_status(log)
  end

  def pdf_viewer(resource)
    if resource.file_upload_updated_at.present? && resource.file_upload_content_type == "application/pdf"
      internal_pdf_link(resource)
    else
      external_pdf_link(resource)
    end
  end

  private

  def quiz_status(log)
    log.quiz_result
  end

  def course_status(log)
    log.element_completed ? 'completed' : 'started'
  end

  # VUEJS component
  def internal_pdf_link(resource)
    viewer = "<div class='pdf-files-elements' data-file-id='#{resource.id}' data-file-name='#{resource.name}' data-file-url='#{resource.file_upload.url}'></div>"
    viewer.html_safe
  end

  def external_pdf_link(resource)
    content_tag(:div, class: 'col-sm-6') do
      content_tag(:div, class: 'card card-horizontal card-horizontal-sm flex-row resource-card', data: { resource_name: resource.name, course_name: resource.course.name, resource_type: resource.type, allowed: 'true' }) do
        content_tag(:div, class: 'card-header bg-white d-flex align-items-center justify-content-center') do
          content_tag(:i, '', class: 'budicon-files-download')
        end +

        link_to(course_resource_special_link(resource), target: :blank, class: 'card-body d-flex align-items-center pl-1') do
          content_tag(:h5, class: 'm-0 text-truncate text-gray2') do
              resource.name
            end
        end
      end
    end
  end
end
