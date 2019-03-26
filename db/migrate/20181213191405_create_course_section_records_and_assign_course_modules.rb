class CreateCourseSectionRecordsAndAssignCourseModules < ActiveRecord::Migration[4.2]
  def change
    SubjectCourse.all.each do |subject_course|
      subject_course.course_modules.each do |course_module|
        if course_module.tuition
          section_name = 'Tuition'
          section_name_url = 'tuition'
        elsif course_module.revision
          section_name = 'Additional Content'
          section_name_url = 'additional-content'
        elsif course_module.test
          section_name = 'Question Bank'
          section_name_url = 'question-bank'
        else
          section_name = 'Extra'
          section_name_url = 'extra'
        end

        if course_module.subject_course
          section = CourseSection.where(subject_course_id: course_module.subject_course_id,name: section_name).first_or_create!(
              subject_course_id: course_module.subject_course_id, name: section_name, name_url: section_name_url,
              active: true, counts_towards_completion: true)

          course_module.update_column(:course_section_id, section.id)
        end
      end
    end
  end
end
