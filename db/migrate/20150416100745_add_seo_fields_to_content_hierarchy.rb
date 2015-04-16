class AddSeoFieldsToContentHierarchy < ActiveRecord::Migration
  def up
    add_column :subject_areas, :seo_description, :string
    add_column :subject_areas, :seo_no_index, :boolean, default: false
    add_column :institutions, :seo_description, :string
    add_column :institutions, :seo_no_index, :boolean, default: false
    add_column :qualifications, :seo_description, :string
    add_column :qualifications, :seo_no_index, :boolean, default: false
    add_column :exam_levels, :seo_description, :string
    add_column :exam_levels, :seo_no_index, :boolean, default: false
    add_column :exam_sections, :seo_description, :string
    add_column :exam_sections, :seo_no_index, :boolean, default: false
    add_column :course_modules, :seo_description, :string
    add_column :course_modules, :seo_no_index, :boolean, default: false
    add_column :course_module_elements, :seo_description, :string
    add_column :course_module_elements, :seo_no_index, :boolean, default: false
    if Rails.env.staging? || Rails.env.development?
      SubjectArea.update_all(seo_description: 'SEO Description goes here')
      Institution.update_all(seo_description: 'SEO Description goes here')
      Qualification.update_all(seo_description: 'SEO Description goes here')
      ExamLevel.update_all(seo_description: 'SEO Description goes here')
      ExamSection.update_all(seo_description: 'SEO Description goes here')
      CourseModule.all.each do |cm|
        if cm.description.blank?
          cm.update(seo_description: 'SEO Description goes here')
        else
          cm.update(seo_description: cm.description.to_s.truncate(200) )
        end
      end
      CourseModuleElement.all.each do |cme|
        if cme.description.blank?
          cme.update(seo_description: 'SEO Description goes here')
        else
          cme.update(seo_description: cme.description.to_s.truncate(200) )
        end
      end
    end
  end

  def down
    remove_column :subject_areas, :seo_description
    remove_column :subject_areas, :seo_no_index
    remove_column :institutions, :seo_description
    remove_column :institutions, :seo_no_index
    remove_column :qualifications, :seo_description
    remove_column :qualifications, :seo_no_index
    remove_column :exam_levels, :seo_description
    remove_column :exam_levels, :seo_no_index
    remove_column :exam_sections, :seo_description
    remove_column :exam_sections, :seo_no_index
    remove_column :course_modules, :seo_description
    remove_column :course_modules, :seo_no_index
    remove_column :course_module_elements, :seo_description
    remove_column :course_module_elements, :seo_no_index
  end
end
