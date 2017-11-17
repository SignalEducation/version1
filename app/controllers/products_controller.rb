# == Schema Information
#
# Table name: products
#
#  id                :integer          not null, primary key
#  name              :string
#  subject_course_id :integer
#  mock_exam_id      :integer
#  stripe_guid       :string
#  live_mode         :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  active            :boolean          default(FALSE)
#  currency_id       :integer
#  price             :decimal(, )
#  stripe_sku_guid   :string
#

class ProductsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(stripe_management_access))
  end
  before_action :get_variables

  def index
    @all_products = Product.paginate(per_page: 50, page: params[:page])
    @products = params[:search].to_s.blank? ?
        @products = @all_products.all_in_order :
        @products = @all_products.search(params[:search])
  end

  def show
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(allowed_params)
    if @product.save
      flash[:success] = I18n.t('controllers.products.create.flash.success')
      redirect_to products_url
    else
      render action: :new
    end
  end


  def update
    if @product.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.products.update.flash.success')
      redirect_to products_url
    else
      render action: :edit
    end
  end

  def destroy
    if @product.destroy
      flash[:success] = I18n.t('controllers.products.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.products.destroy.flash.error')
    end
    redirect_to products_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @product = Product.where(id: params[:id]).first
    end
    @currencies = Currency.all_in_order
    @mock_exams = MockExam.all_in_order
    @subject_courses = SubjectCourse.all_active.all_in_order
    seo_title_maker(@product.try(:name) || 'Products', '', true)
    @navbar = false
    @footer = false
    @top_margin = false
  end

  def allowed_params
    params.require(:product).permit(:name, :active, :price, :currency_id, :livemode, :mock_exam_id)
  end

end
