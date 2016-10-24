# == Schema Information
#
# Table name: student_user_types
#
#  id            :integer          not null, primary key
#  name          :string
#  description   :text
#  subscription  :boolean          default(FALSE)
#  product_order :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  free_trial    :boolean          default(FALSE)
#

class StudentUserTypesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @student_user_types = StudentUserType.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @student_user_type = StudentUserType.new
  end

  def edit
  end

  def create
    @student_user_type = StudentUserType.new(allowed_params)
    if @student_user_type.save
      flash[:success] = I18n.t('controllers.student_user_types.create.flash.success')
      redirect_to student_user_types_url
    else
      render action: :new
    end
  end

  def update
    if @student_user_type.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.student_user_types.update.flash.success')
      redirect_to student_user_types_url
    else
      render action: :edit
    end
  end


  def destroy
    if @student_user_type.destroy
      flash[:success] = I18n.t('controllers.student_user_types.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.student_user_types.destroy.flash.error')
    end
    redirect_to student_user_types_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @student_user_type = StudentUserType.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:student_user_type).permit(:name, :description, :subscription, :product_order, :free_trial)
  end

end
