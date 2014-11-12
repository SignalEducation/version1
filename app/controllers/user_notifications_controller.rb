class UserNotificationsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @user_notifications = UserNotification.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @user_notification = UserNotification.new
  end

  def edit
  end

  def create
    @user_notification = UserNotification.new(allowed_params)
    @user_notification.user_id = current_user.id
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
      @user_notification = UserNotification.where(id: params[:id]).first
    end
    @users = User.all_in_order
    @forum_topics = ForumTopic.all_in_order
    @forum_posts = ForumPost.all_in_order
    @tutors = Tutor.all_in_order
    @blog_posts = BlogPost.all_in_order
  end

  def allowed_params
    params.require(:user_notification).permit(:user_id, :subject_line, :content, :email_required, :email_sent_at, :unread, :destroyed_at, :message_type, :forum_topic_id, :forum_post_id, :tutor_id, :falling_behind, :blog_post_id)
  end

end
