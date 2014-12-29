class StaticPageUploadsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'content_manager'])
  end

  def create
    @static_page_upload = StaticPageUpload.new(allowed_params)
    if @static_page_upload.save
      render :show, layout: false
    else
      render json: @static_page_upload.errors, status: :unprocessable_entity
    end
  end

  protected

  def allowed_params
    params.require(:static_page_upload).permit(:description, :static_page_id, :upload, :upload_file_name, :upload_content_type, :upload_file_size, :upload_updated_at)
  end
end
