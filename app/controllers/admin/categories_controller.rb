# frozen_string_literal: true

module Admin
  class CategoriesController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :set_category, only: %i[show edit update]

    def index
      @categories = Category.all
    end

    def new
      @category = Category.new
    end

    def show; end

    def create
      @category = Category.new(category_params)

      if @category.save
        flash[:success] = t('controllers.categorys.create.success')
        redirect_to admin_categories_path
      else
        flash[:error] = t('controllers.categorys.create.error')
        render action: :new
      end
    end

    def update
      if @category.update(category_params)
        flash[:success] = t('controllers.category.update.success')
        redirect_to admin_categories_path
      else
        flash[:error] = t('controllers.category.update.error')
        redirect_to edit_admin_category_path(@category)
      end
    end

    def edit; end

    protected

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :name_url, :description, :active)
    end
  end
end
