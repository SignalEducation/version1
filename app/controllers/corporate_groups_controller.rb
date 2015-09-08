class CorporateGroupsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'corporate_customer'])
  end
  before_action :get_variables

  def index
    @corporate_groups = []
    if current_user.admin?
      @corporate_groups = CorporateGroup.paginate(per_page: 50, page: params[:page]).all_in_order
      @corporate_customers =CorporateCustomer.all
    elsif current_user.corporate_customer? && current_user.corporate_customer_id
      @corporate_groups = CorporateGroup
                          .where(corporate_customer_id: current_user.corporate_customer_id)
                          .paginate(per_page: 50, page: params[:page]).all_in_order
    end
    @corporate_groups
    if current_user.corporate_customer?
      @corporate_customer = CorporateCustomer.where(id: current_user.corporate_customer_id).first
    end
  end

  def new
    @corporate_group = current_user.admin? ?
                         CorporateGroup.new :
                         CorporateGroup.new(corporate_customer_id: current_user.corporate_customer_id)
  end

  def edit
    if current_user.corporate_customer? && current_user.corporate_customer_id != @corporate_group.corporate_customer_id
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to corporate_groups_url
    end
  end

  def edit_members
    @corporate_group = CorporateGroup.find(params[:corporate_group_id]) rescue nil
    if @corporate_group.nil? ||
       (current_user.corporate_customer? && current_user.corporate_customer_id != @corporate_group.corporate_customer_id)
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to corporate_groups_url
    end
  end

  def create
    @corporate_group = CorporateGroup.new(allowed_params)
    if (current_user.admin? || current_user.corporate_customer_id == @corporate_group.corporate_customer_id) &&
       @corporate_group.save
      process_grants
      flash[:success] = I18n.t('controllers.corporate_groups.create.flash.success')
      redirect_to corporate_groups_url
    else
      render action: :new
    end
  end

  def update
    name = allowed_params[:name]
    if (current_user.admin? || current_user.corporate_customer_id == @corporate_group.corporate_customer_id) &&
       @corporate_group.update_attributes(name: name)
      process_grants
      flash[:success] = I18n.t('controllers.corporate_groups.update.flash.success')
      redirect_to corporate_groups_url
    else
      render action: :edit
    end
  end

  def update_members
    @corporate_group = CorporateGroup.find(params[:corporate_group_id]) rescue nil
    if @corporate_group &&
       (current_user.admin? || current_user.corporate_customer_id == @corporate_group.corporate_customer_id)
      @corporate_group.user_ids = params[:corporate_group][:corporate_student_ids]
      flash[:success] = I18n.t('controllers.corporate_groups.update_members.flash.success')
      redirect_to corporate_groups_url
    else
      render action: :edit_members
    end
  end

  def destroy
    if (current_user.admin? || current_user.corporate_customer_id == @corporate_group.corporate_customer_id) &&
       @corporate_group &&
       @corporate_group.destroy
      flash[:success] = I18n.t('controllers.corporate_groups.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.corporate_groups.destroy.flash.error')
    end
    redirect_to corporate_groups_url
  end

  protected

  def get_variables
    @corporate_customers = CorporateCustomer.all
    if params[:id].to_i > 0
      @corporate_group = CorporateGroup.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:corporate_group).permit(:corporate_customer_id,
                                            :name)
  end

  # Method is extremely unoptimised because feature must be finished
  # before Philip's meeting. After meeting it has to be optimised and
  # acompanying specs must be implemented.
  def process_grants
    # First we will update existing grants or destroy
    # them if flags were cleared.
    exam_section_ids = params[:exam_sections].try(:keys) || []
    exam_level_ids = params[:exam_levels].try(:keys) || []
    remove_grants = []
    @corporate_group.corporate_group_grants.each do |cgg|
      if cgg.exam_section_id && cgg.exam_level_id.nil?
        if exam_section_ids.include?(cgg.exam_section_id.to_s)
          cgg.compulsory = params[:exam_sections][cgg.exam_section_id.to_s] == "compulsory"
          cgg.restricted = params[:exam_sections][cgg.exam_section_id.to_s] == "restricted"
          cgg.save
          exam_section_ids.delete(cgg.exam_section_id.to_s)
        else
          cgg.destroy
        end
      elsif cgg.exam_section_id.nil? && cgg.exam_level_id
        if exam_level_ids.include?(cgg.exam_level_id.to_s)
          cgg.compulsory = params[:exam_levels][cgg.exam_level_id.to_s] == "compulsory"
          cgg.restricted = params[:exam_levels][cgg.exam_level_id.to_s] == "restricted"
          exam_level_ids.delete(cgg.exam_level_id.to_s)
          cgg.save
        else
          cgg.destroy
        end
      else
        Rails.logger.error "ERROR: Inconsistent state (both are set) of exam level and exam section ids for corporate group grant #{cgg.id}"
      end
    end

    # Now let's add new ones.
    exam_section_ids.each do |exi|
      @corporate_group.corporate_group_grants.create(exam_section_id: exi,
                                                     compulsory: params[:exam_sections][exi] == "compulsory",
                                                     restricted: params[:exam_sections][exi] == "restricted")
    end

    exam_level_ids.each do |eli|
      @corporate_group.corporate_group_grants.create(exam_level_id: eli,
                                                     compulsory: params[:exam_levels][eli] == "compulsory",
                                                     restricted: params[:exam_levels][eli] == "restricted")
    end
  end
end
