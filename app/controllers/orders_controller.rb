# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  product_id                :integer
#  subject_course_id         :integer
#  user_id                   :integer
#  stripe_guid               :string
#  stripe_customer_id        :string
#  live_mode                 :boolean          default(FALSE)
#  current_status            :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default(FALSE)
#

class OrdersController < ApplicationController

  before_action :logged_in_required
  before_action except: [:new, :create, :mock_exam_create] do
    ensure_user_is_of_type(['admin'])
  end
  before_action only: [:new, :create] do
    ensure_user_is_of_type(['individual_student'])
  end
  before_action :get_variables

  def index
    @orders = Order.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    redirect_to new_product_user_url(@course.name_url) unless current_user.individual_student?
    if current_user.valid_subject_course_ids.include?(@course.id)
      redirect_to diploma_course_url(@course.name_url)
    else
      @order = Order.new
      @product = Product.where(subject_course_id: @course.id).first
      @navbar = false
      @footer = false
    end
  end

  def create
    if current_user && params[:order] && params[:order][:subject_course_id] && params[:order][:stripe_token] && params[:order][:terms_and_conditions]

      user = current_user
      subject_course_id = params[:order][:subject_course_id]
      product = Product.find_by_subject_course_id(subject_course_id)
      @course = product.subject_course
      currency = Currency.find(product.currency_id)
      stripe_token = params[:order][:stripe_token]
      redirect_to diploma_course_url(@course.name_url) if current_user.valid_subject_course_ids.include?(params[:order][:subject_course_id])

      @order = Order.new(allowed_params)
      @order.user_id = user.id
      @order.product_id = product.id
      @order.terms_and_conditions = params[:order][:terms_and_conditions]

      stripe_order = Stripe::Order.create(
          currency: currency.iso_code,
          customer: user.stripe_customer_id,
          email: user.email,
          items: [{
                      amount: (product.price.to_f * 100).to_i,
                      currency: currency.iso_code,
                      quantity: 1,
                      parent: product.stripe_sku_guid
                  }]
      )

      @order.stripe_customer_id = stripe_order.customer
      @order.stripe_guid = stripe_order.id
      @order.live_mode = stripe_order.livemode
      @order.current_status = stripe_order.status

      if @order.valid?
        order = Stripe::Order.retrieve(@order.stripe_guid)
        @pay_order = order.pay(source: stripe_token)
      end
      order = Stripe::Order.retrieve(@order.stripe_guid)
      @order.current_status = order.status
      @order.stripe_order_payment_data = @pay_order
      #user.update_student_user_type(@order)
      if user.student_user_type_id == StudentUserType.default_no_access_user_type.id
        new_user_type_id = StudentUserType.default_product_user_type.id
      elsif user.student_user_type_id == StudentUserType.default_free_trial_user_type.id
        new_user_type_id = StudentUserType.default_free_trial_and_product_user_type.id
      elsif user.student_user_type_id == StudentUserType.default_sub_user_type.id
        new_user_type_id = StudentUserType.default_sub_and_product_user_type.id
      else
        new_user_type_id = user.student_user_type_id
      end
      user.update_attributes(student_user_type_id: new_user_type_id)
    else
      redirect_to new_order_url
    end

    if @order.save
      flash[:success] = I18n.t('controllers.orders.create.flash.success')
      redirect_to new_order_enrollment_url(@course.name_url)
    else
      render action: :new
    end
  end

  def mock_exam_create
    if current_user && params[:order] && params[:order][:mock_exam_id] && params[:order][:stripe_token]

      user = current_user
      mock_exam_id = params[:order][:mock_exam_id]
      @mock_exam = MockExam.find(mock_exam_id)
      product = @mock_exam.product
      currency = Currency.find(product.currency_id)
      stripe_token = params[:order][:stripe_token]
      #redirect_to media_library_url if current_user.valid_subject_course_ids.include?(params[:order][:subject_course_id])

      @order = Order.new(allowed_params)
      @order.user_id = user.id
      @order.product_id = product.id

      stripe_order = Stripe::Order.create(
          currency: currency.iso_code,
          customer: user.stripe_customer_id,
          email: user.email,
          items: [{
                      amount: (product.price.to_f * 100).to_i,
                      currency: currency.iso_code,
                      quantity: 1,
                      parent: product.stripe_sku_guid
                  }]
      )

      @order.stripe_customer_id = stripe_order.customer
      @order.stripe_guid = stripe_order.id
      @order.live_mode = stripe_order.livemode
      @order.current_status = stripe_order.status

      if @order.valid?
        order = Stripe::Order.retrieve(@order.stripe_guid)
        @pay_order = order.pay(source: stripe_token)
      end
      order = Stripe::Order.retrieve(@order.stripe_guid)
      @order.current_status = order.status
      @order.stripe_order_payment_data = @pay_order
    else
      redirect_to media_library_url
    end

    if @order.save
      flash[:success] = I18n.t('controllers.orders.create.flash.mock_exam_success')
      MandrillWorker.perform_async(user.id, 'send_mock_exam_email', account_url, @mock_exam.name, @mock_exam.file)
      redirect_to account_url(anchor: :orders)
    else
      redirect_to media_library_url
    end
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @order = Order.where(id: params[:id]).first
    end
    @product_category = SubjectCourseCategory.all_product.first
    @courses = SubjectCourse.all_active.all_in_order.in_category(@product_category.id)
  end

  def allowed_params
    params.require(:order).permit(:subject_course_id, :user_id, :stripe_token, :mock_exam_id, :terms_and_conditions)
  end

end
