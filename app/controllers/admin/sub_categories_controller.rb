# frozen_string_literal: true

module Admin
  class SubCategoriesController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :set_sub_category, only: %i[show edit update]

    def index
      @sub_categories = SubCategory.all
    end

    def new
      @categories   = Category.all_active
      @sub_category = SubCategory.new
    end

    def show
      @category = @sub_category.category
    end

    def create
      @sub_category = SubCategory.new(sub_category_params)

      if @sub_category.save
        flash[:success] = t('controllers.sub_category.create.success')
        redirect_to admin_sub_categories_path
      else
        flash[:error] = t('controllers.sub_category.create.error')
        render action: :new
      end
    end

    def update
      if @sub_category.update(sub_category_params)
        flash[:success] = t('controllers.sub_category.update.success')
        redirect_to admin_sub_categories_path
      else
        flash[:error] = t('controllers.sub_category.update.error')
        redirect_to edit_admin_sub_category_path(@sub_category)
      end
    end

    def edit
      @categories   = Category.all_active
    end

    protected

    def set_sub_category
      @sub_category = SubCategory.find(params[:id])
    end

    def sub_category_params
      params.require(:sub_category).permit(:name, :name_url, :description, :category_id, :active)
    end
  end
end
