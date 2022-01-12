# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[stripe_management_access]) }
  before_action :seo_title,         except: :reorder
  before_action :management_layout, except: :reorder
  before_action :set_product, only: %i[show edit update destroy]
  before_action :set_variables, only: %i[new create edit update]

  def index
    @products = Product.includes(:currency, :mock_exam, :orders).
                  search(params[:search]).
                  filter_by_state(params[:state]).
                  all_in_order
  end

  def show; end

  def new
    @product = Product.new
    @product.faqs.build(sorting_order: 1)
  end

  def edit
    @product.faqs.build(sorting_order: 1)
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

  def reorder
    ids = params[:array_of_ids]

    ids.each_with_index do |id, counter|
      Product.find(id).update(sorting_order: (counter + 1))
    end

    render json: {}, status: :ok
  end

  def update
    if @product.update(allowed_params)
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

  def set_product
    @product = Product.find(params[:id])
  end

  def set_variables
    @currencies = Currency.all_in_order
    @mock_exams = MockExam.all_in_order
    @cbes       = Cbe.all
    @courses    = Course.all_active.all_in_order
    @groups     = Group.all_in_order
  end

  def seo_title
    seo_title_maker(@product.try(:name) || 'Products', '', true)
  end

  def allowed_params
    params.require(:product).permit(:name, :active, :price, :currency_id, :livemode,
                                    :cbe_id, :mock_exam_id, :sorting_order,
                                    :product_type, :correction_pack_count, :group_id,
                                    :payment_heading, :payment_subheading, :payment_description,
                                    :savings_label, :course_id, :months_to_expiry,
                                    faqs_attributes: [
                                      :id, :name, :name_url, :active, :sorting_order,
                                      :question_text, :answer_text, :pre_answer_text,
                                      :_destroy]
                                    )
  end
end
