# frozen_string_literal: true

class CourseCloneWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(course_id, user_id, url)
    user        = User.find(user_id)
    course      = Course.find(course_id)
    course_name = "#{course.name} copy"
    cloned      = course.duplicate

    if cloned.is_a?(Course)
      send_successfully_email(user, url + "/#{cloned.id}", course_name)
    else
      send_failed_email(user, url, course_name, cloned.message)
    end
  end

  private

  def send_successfully_email(user, url, course_name)
    MandrillClient.new(user).send('successfully_course_clone_email', user.name, url, course_name)
  end

  def send_failed_email(user, url, course_name, error)
    MandrillClient.new(user).send('failed_course_clone_email', user.name, url, course_name, error)
  end
end
