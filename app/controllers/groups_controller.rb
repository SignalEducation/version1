# == Schema Information
#
# Table name: groups
#
#  id                            :integer          not null, primary key
#  name                          :string
#  name_url                      :string
#  active                        :boolean          default(FALSE), not null
#  sorting_order                 :integer
#  description                   :text
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  destroyed_at                  :datetime
#  image_file_name               :string
#  image_content_type            :string
#  image_file_size               :integer
#  image_updated_at              :datetime
#  background_image_file_name    :string
#  background_image_content_type :string
#  background_image_file_size    :integer
#  background_image_updated_at   :datetime
#

class GroupsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables

  # Standard Actions #
  def index
    @groups = Group.paginate(per_page: 50, page: params[:page])
  end

  def show
    @group = Group.find(params[:id])
    @courses = @group.children
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
    @group = Group.where(name_url: params[:group_name_url]).first || Group.where(id: params[:id]).first
    @navbar = false
    @footer = false
    @top_margin = false
  end

  def allowed_params
    params.require(:group).permit(:name, :name_url, :active, :sorting_order, :description, :image, :background_image)
  end

end
