class GroupsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @groups = Group.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @group = Group.new
  end

  def edit
  end

  def create
    @group = Group.new(allowed_params)
    if @group.save
      flash[:success] = I18n.t('controllers.groups.create.flash.success')
      redirect_to groups_url
    else
      render action: :new
    end
  end

  def update
    if @group.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.groups.update.flash.success')
      redirect_to groups_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      Group.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @group.destroy
      flash[:success] = I18n.t('controllers.groups.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.groups.destroy.flash.error')
    end
    redirect_to groups_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @group = Group.where(id: params[:id]).first
    end
    #@subjects = Subject.all_in_order
  end

  def allowed_params
    params.require(:group).permit(:name, :name_url, :active, :sorting_order, :description, :subject_id)
  end

end
