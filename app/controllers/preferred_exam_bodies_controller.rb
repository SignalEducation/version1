class PreferredExamBodiesController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(student_user))
  end
  before_action :set_user

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to new_subscription_path(exam_body_id: @user.preferred_exam_body_id)
    else
      render :edit
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:preferred_exam_body_id)
  end
end
