class CreateCourseSectionRecordsAndAssignCourseModules < ActiveRecord::Migration
  def change
    SubjectCourse.find_each do |subject_course|
      tuition_section = CourseSection.create(subject_course_id: subject_course.id, name: 'Tuition',
                           name_url: 'tuition', sorting_order: 1, active: true, counts_towards_completion: true)
      additional_section = CourseSection.create(subject_course_id: subject_course.id, name: 'Additional Content',
                           name_url: 'additional-content', sorting_order: 2, active: true, counts_towards_completion: true)
      question_bank_section = CourseSection.create(subject_course_id: subject_course.id, name: 'Question Bank',
                           name_url: 'question-bank', sorting_order: 3, active: true, counts_towards_completion: true)
      other_section = CourseSection.create(subject_course_id: subject_course.id, name: 'Other',
                           name_url: 'other', sorting_order: 4, active: false, counts_towards_completion: false)

      subject_course.course_modules.each do |course_module|
        if course_module.tuition
          section_id =  tuition_section.id
        elsif course_module.revision
          section_id =  question_bank_section.id
        elsif course_module.test
          section_id =  additional_section.id
        else
          section_id =  other_section.id
        end
        course_module.update_column(:course_section_id, section_id)
      end
    end

  end
end
