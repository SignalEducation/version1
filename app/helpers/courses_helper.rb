# frozen_string_literal: true

module CoursesHelper
  def course_lesson_status(course_lesson, exam_tracks, completed_ids)
    exam_tracks && completed_ids.include?(course_lesson.id) ? 'completed' : ''
  end

  def course_element_user_log_status(log)
    return '' if log.nil?

    log.is_quiz? ? quiz_status(log) : course_status(log)
  end

  def pdf_viewer(resource, banner, user)
    if resource.file_upload_updated_at.present? && resource.file_upload_content_type == 'application/pdf'
      internal_pdf_link(resource, banner, user)
    else
      external_pdf_link(resource, banner, user)
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
  def internal_pdf_link(resource, banner, user)
    viewer = "<div class='pdf-files-elements' id: 'resource-window' data-file-id='#{resource&.id}' data-file-name='#{resource&.name}' data-file-url='#{resource&.file_upload&.url}' data-file-download='#{resource&.download_available}' data-course-name='#{resource&.course&.name}' data-course-id='#{resource&.course_id}' data-onboarding='#{user&.analytics_onboarding_valid?.to_s}' data-banner='#{banner}' data-preferred-exam-body-id='#{user&.preferred_exam_body_id}' data-preferred-exam-body-name='#{user&.preferred_exam_body&.name}' data-exam-body-id='#{resource&.course&.exam_body_id}' data-exam-body-name='#{resource&.course&.exam_body&.name}'></div>"
    viewer.html_safe
  end

  def external_pdf_link(resource, banner, user)
    content_tag(:div, class: 'col-md-4 col-lg-3 mb-4') do
      link_to(course_resource_special_link(resource), target: :blank, id: 'resource-window', class: 'productCard external-card', data: { resource_name: resource.name, resource_id: resource.id, course_name: resource.course.name, course_id: resource.course_id,
                                                                                                                                preferred_exam_body_id: user&.preferred_exam_body_id, preferred_exam_body: user&.preferred_exam_body&.name, banner: banner,
                                                                                                                                onboarding: user&.analytics_onboarding_valid?.to_s, exam_body_name: resource.course.exam_body.name, exam_body_id: resource.course.exam_body_id,
                                                                                                                                resource_type: resource.type, allowed: true }) do
        content_tag(:div, class: 'productCard-header d-flex align-items-center justify-content-center') do
          # content_tag(:i, '', class: 'budicon-files-download')
          image_tag('course-addon-icons/addon-correction-pack.svg')
        end +

        content_tag(:div, class: 'productCard-body d-flex align-items-center') do
          content_tag(:div, class: '') do
            resource.name
          end +
          content_tag(:div, class: 'productCard-footer d-flex align-items-center justify-content-between') do
            content_tag(:div, '', class: '') do
              content_tag(:span, style:"color: #007bff;background-color: rgb(0 123 255 / 5%);font-size: 14px;border-radius: 4px;padding: 0.5rem 1rem;letter-spacing: 1px;font-weight: 600;line-height: 1;display: inline-flex;column-gap: 6px;") do
                '🎉 FREE'
              end
            end +
            content_tag(:div, '', class: 'btn btn-primary productCard--buyBtn') do
              'View'
            end
          end
        end
      end
    end
  end
end
