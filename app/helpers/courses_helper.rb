# frozen_string_literal: true

module CoursesHelper
  def course_lesson_status(course_lesson, exam_tracks, completed_ids)
    exam_tracks && completed_ids.include?(course_lesson.id) ? 'completed' : ''
  end

  def course_element_user_log_status(log)
    return '' if log.nil?

    log.is_quiz? ? quiz_status(log) : course_status(log)
  end

  def pdf_viewer(resource, banner, user, has_valid_subscription)
    if resource.file_upload_updated_at.present? && resource.file_upload_content_type == 'application/pdf'
      internal_pdf_link(resource, banner, user, has_valid_subscription)
    else
      external_pdf_link(resource, banner, user, has_valid_subscription)
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
  def internal_pdf_link(resource, banner, user, has_valid_subscription)
    viewer = "<div class='pdf-files-elements' id: 'resource-window' data-has-valid-subscription='#{!!has_valid_subscription}' data-file-id='#{resource&.id}' data-file-name='#{resource&.name}' data-file-url='#{resource&.file_upload&.url}' data-file-download='#{resource&.download_available}' data-course-name='#{resource&.course&.name}' data-course-id='#{resource&.course_id}' data-onboarding='#{user&.analytics_onboarding_valid?.to_s}' data-banner='#{banner}' data-preferred-exam-body-id='#{user&.preferred_exam_body_id}' data-preferred-exam-body-name='#{user&.preferred_exam_body&.name}' data-exam-body-id='#{resource&.course&.exam_body_id}' data-exam-body-name='#{resource&.course&.exam_body&.name}' data-user-id= '#{user&.id}' data-email= '#{user&.email}' data-is-email-verified= '#{user&.email_verified}' data-logged-in= '#{!user&.nil?}' data-session-id= '#{session&.id}'></div>"
    viewer.html_safe
  end

  def external_pdf_link(resource, banner, user, has_valid_subscription)
    content_tag(:div, class: 'col-md-4 col-lg-3 mb-4 px-3') do
      link_to(course_resource_special_link(resource), target: :blank, id: 'resource-window', onclick: "sendClickEventToSegment('click_course_resources', {userId: '#{user&.id}',email: '#{user&.email}',hasValidSubscription: '#{user&.valid_subscription?}', isEmailVerified: '#{user&.email_verified}', preferredExamBodyId: '#{user&.preferred_exam_body_id}', isLoggedIn: '#{!user&.nil?}', sessionId: '#{session&.id}', resourceName: '#{resource&.name}', courseName: '#{resource&.course&.name}', programName: '#{resource&.course&.group&.name}'})", class: "productCard external-card has-#{!!has_valid_subscription}-subscription", data: { resource_name: resource.name, resource_id: resource.id, course_name: resource.course.name, course_id: resource.course_id,
                                                                                                                                preferred_exam_body_id: user&.preferred_exam_body_id, preferred_exam_body: user&.preferred_exam_body&.name, banner: banner,
                                                                                                                                onboarding: user&.analytics_onboarding_valid?.to_s, exam_body_name: resource.course.exam_body.name, exam_body_id: resource.course.exam_body_id,
                                                                                                                                resource_type: resource.type, allowed: true }) do
        content_tag(:div, class: 'productCard-header d-flex align-items-center justify-content-center') do
          image_tag('course-addon-icons/addon-correction-pack.svg')
        end +

        content_tag(:div, class: 'productCard-body d-flex align-items-center') do
          content_tag(:div, class: '') do
            resource.name
          end +
          content_tag(:div, class: 'productCard-footer d-flex align-items-center justify-content-between') do
            content_tag(:div, class: '') do
              content_tag(:span, class: 'productCard-statusLabel') do
                '🎉 FREE'
              end
            end +
            content_tag(:div, class: 'btn btn-primary productCard--buyBtn') do
              'View'
            end
          end
        end
      end
    end
  end
end
