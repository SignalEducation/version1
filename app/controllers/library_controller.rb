class LibraryController < ApplicationController

  def show
    @hierarchy_item = @subject_area = @institution = @qualification = @exam_level = @exam_section = nil
    @hierarchy_item = @subject_area = SubjectArea.where(name_url: params[:subject_area_name_url].to_s).first || SubjectArea.all_active.all_in_order.first
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
  end

  protected

end
