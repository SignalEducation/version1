class WhitePapersController < ApplicationController

  before_action :logged_in_required, except: [:index, :show]
  before_action do
    ensure_user_is_of_type(['admin', 'content_manager'])
  end
  before_action :get_variables

  def index
    @white_papers = WhitePaper.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def media_library
    @white_papers = WhitePaper.all_in_order
  end

  def show
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

  protected

  def get_variables
    if params[:id].to_i > 0
      @white_paper = WhitePaper.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:white_paper).permit(:title, :description, :file, :sorting_order, :cover_image)
  end

end
