# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[content_management_access]) }
  before_action :management_layout
  before_action :get_variables

  def index
    @groups = Group.paginate(per_page: 50, page: params[:page])
  end

  def show
    @group = Group.find(params[:id])
    @courses = @group.children
  end

  def new
    @group = Group.new
    @group.levels.build
  end

  def edit
    @group.levels.build
  end

  def create
    @group = Group.new(allowed_params)

    if @group.save
      flash[:success] = I18n.t('controllers.groups.create.flash.success')
      redirect_to groups_url
    else
      render :new
    end
  end

  def update
    if @group.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.groups.update.flash.success')
      redirect_to groups_url
    else
      render :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      Group.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: :ok
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
    @group = Group.where(name_url: params[:group_name_url]).first || Group.where(id: params[:id]).first
  end

  def allowed_params
    params.require(:group).permit(:name, :name_url, :active, :sorting_order,
                                  :description, :image, :background_image,
                                  :background_colour, :exam_body_id,
                                  :seo_title, :seo_description, :short_description,
                                  :onboarding_level_heading, :onboarding_level_subheading,
                                  :tab_view, :disclaimer, :category_id, :sub_category_id)
  end
end
