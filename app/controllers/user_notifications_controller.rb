# == Schema Information
#
# Table name: user_notifications
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  subject_line   :string
#  content        :text
#  email_required :boolean          default(FALSE), not null
#  email_sent_at  :datetime
#  unread         :boolean          default(TRUE), not null
#  destroyed_at   :datetime
#  message_type   :string
#  tutor_id       :integer
#  falling_behind :boolean          not null
#  blog_post_id   :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class UserNotificationsController < ApplicationController

  before_action :logged_in_required
  before_action except: [:index, :show, :destroy, :update] do
    ensure_user_is_of_type(['admin', 'tutor'])
  end
  before_action :get_variables

  def index
    if current_user.admin?
      @user_notifications = UserNotification.paginate(per_page: 50, page: params[:page]).all_in_order
    else
      @user_notifications = current_user.user_notifications.paginate(per_page: 50, page: params[:page]).all_in_order
    end
  end

  def show
    @user_notification.update_attributes(unread: false) if @user_notification.unread
  end

  def new
    @user_notification = UserNotification.new
  end

  def edit
  end

  def create
    @user_notification = UserNotification.new(allowed_params)
    @user_notification.falling_behind = false
    if @user_notification.save
      flash[:success] = I18n.t('controllers.user_notifications.create.flash.success')
      redirect_to user_notifications_url
    else
      render action: :new
    end
  end

  def update
    if @user_notification.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.user_notifications.update.flash.success')
      redirect_to user_notifications_url
    else
      render action: :edit
    end
  end

  def destroy
    if @user_notification.destroy
      flash[:success] = I18n.t('controllers.user_notifications.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.user_notifications.destroy.flash.error')
    end
    redirect_to user_notifications_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      if current_user.try(:admin?)
        @user_notification = UserNotification.where(id: params[:id]).first
        @users = User.all_in_order
      else
        @user_notification = current_user.user_notifications.find_by_id(params[:id].to_i)
        if current_user.tutor?
          @users = User.all_in_order
        else
          @users = User.none
        end
      end
    end
    if params[:id].to_i > 0 && @user_notification.nil?
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to root_url
      return false
    end
    #@tutors = Tutor.all_in_order
    #@blog_posts = BlogPost.all_in_order
    seo_title_maker(@user_notification.try(:subject_line) || 'User Notifications', '', true)
  end

  def allowed_params
    params.require(:user_notification).permit(:user_id, :subject_line, :content,
                                              :email_required, :email_sent_at,
                                              :unread, :destroyed_at, :message_type,
                                              :tutor_id, :falling_behind,
                                              :blog_post_id)
  end

end
