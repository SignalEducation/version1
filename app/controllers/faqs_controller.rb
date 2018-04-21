# == Schema Information
#
# Table name: faqs
#
#  id             :integer          not null, primary key
#  name           :string
#  name_url       :string
#  active         :boolean          default(TRUE)
#  sorting_order  :integer
#  faq_section_id :integer
#  question_text  :text
#  answer_text    :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class FaqsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(content_management_access marketing_resources_access))
  end
  before_action :get_variables

  def new
    @faq = Faq.new(sorting_order: 1, faq_section_id: params[:faq_section_id])
  end

  def edit
  end

  def create
    @faq = Faq.new(allowed_params)
    if @faq.save
      flash[:success] = I18n.t('controllers.faqs.create.flash.success')
      redirect_to public_resources_url
    else
      render action: :new
    end
  end

  def update
    if @faq.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.faqs.update.flash.success')
      redirect_to public_resources_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      Faq.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @faq.destroy
      flash[:success] = I18n.t('controllers.faqs.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.faqs.destroy.flash.error')
    end
    redirect_to public_resources_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @faq = Faq.where(id: params[:id]).first
    end
    @faq_sections = FaqSection.all_in_order
    @layout = 'management'
  end

  def allowed_params
    params.require(:faq).permit(:name, :name_url, :active, :sorting_order, :faq_section_id, :question_text, :answer_text)
  end

end
