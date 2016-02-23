class StudentSignUpsController < ApplicationController
  def show
    @courses = SubjectCourse.all_active.all_live.all_in_order
  end
end
