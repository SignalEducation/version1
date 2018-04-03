# == Schema Information
#
# Table name: white_papers
#
#  id                       :integer          not null, primary key
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_file_name           :string
#  file_content_type        :string
#  file_file_size           :integer
#  file_updated_at          :datetime
#  sorting_order            :integer
#  cover_image_file_name    :string
#  cover_image_content_type :string
#  cover_image_file_size    :integer
#  cover_image_updated_at   :datetime
#  name_url                 :string
#  name                     :string
#  subject_course_id        :integer
#

class WhitePapersController < ApplicationController

  before_action :logged_in_required, except: [:show, :create_request, :media_library]
  before_action except: [:show, :create_request, :media_library] do
    ensure_user_has_access_rights(%w(content_management_access marketing_resources_access))
  end
  before_action :get_variables, except: [:show]

  def index
    @white_papers = WhitePaper.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def media_library
    @layout = 'standard'
    @white_papers = WhitePaper.all_in_order

    mock_exams = MockExam.all_in_order
    mock_exam_ids = mock_exams.map(&:id)
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : current_user.country
    @currency_id = @country.currency_id
    @products = Product.includes(:currency).in_currency(@currency_id).all_active.all_in_order.where(mock_exam_id: mock_exam_ids)

  end

  def show
    @layout = 'standard'
    @white_paper = WhitePaper.where(name_url: params[:white_paper_name_url]).first
    @white_paper_request = WhitePaperRequest.new(white_paper_id: @white_paper.id)
  end

  def new
    @white_paper = WhitePaper.new
  end

  def edit
  end

  def create
    @white_paper = WhitePaper.new(allowed_params)
    if @white_paper.save
      flash[:success] = I18n.t('controllers.white_papers.create.flash.success')
      redirect_to white_papers_url
    else
      render action: :new
    end
  end

  def update
    if @white_paper.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.white_papers.update.flash.success')
      redirect_to white_papers_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      WhitePaper.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @white_paper.destroy
      flash[:success] = I18n.t('controllers.white_papers.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.white_papers.destroy.flash.error')
    end
    redirect_to white_papers_url
  end

  def create_request
    @layout = 'standard'
    @white_paper_request = WhitePaperRequest.new(request_allowed_params)
    if @white_paper_request.save
      flash[:success] = I18n.t('controllers.white_paper_requests.create.flash.success')
      white_paper = WhitePaper.where(id: @white_paper_request.white_paper_id).first
      file  = white_paper.file

      WhitePaperEmailWorker.perform_async(@white_paper_request.name ,@white_paper_request.email, 'send_white_paper_request_email', @white_paper_request.name, white_paper.name, file.url) unless Rails.env.test?
      redirect_to public_white_paper_url(white_paper.name_url)
    else
      render action: :new
    end

  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @white_paper = WhitePaper.where(id: params[:id]).first
    end
    @subject_courses = SubjectCourse.all_active.all_in_order
    @layout = 'management'
  end

  def allowed_params
    params.require(:white_paper).permit(:name, :description, :file, :sorting_order, :cover_image, :name_url, :subject_course_id)
  end

  def request_allowed_params
    params.require(:white_paper_request).permit(:name, :email, :number, :company_name, :white_paper_id)
  end

end
