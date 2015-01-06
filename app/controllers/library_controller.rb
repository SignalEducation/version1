class LibraryController < ApplicationController

  def show
    @subject_areas = SubjectArea.all_active.all_in_order
    @subject_area = @institution = @qualification = @exam_level = @exam_section = nil
    @subject_area = @subject_areas.where(name_url: params[:subject_area_name_url].to_s).first || @subject_areas.first
    if @subject_area
      @institution = @subject_area.institutions.where(name_url: params[:institution_name_url]).first
      if @institution
        @qualification = @institution.qualifications.where(name_url: params[:qualification_name_url]).first
        if @qualification
          @exam_level = @qualification.exam_levels.where(name_url: params[:exam_level_name_url]).first
          if @exam_level && params[:exam_section_name_url] && params[:exam_section_name_url] != 'all'
            @exam_section = @exam_level.exam_sections.where(name_url: params[:exam_section_name_url]).first
          end
        end
      end
    end
    @hierarchy_item = @exam_section || @exam_level || @qualification || @institution || @subject_area
  end

  protected

end
