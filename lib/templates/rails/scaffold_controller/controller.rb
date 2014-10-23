class <%= table_name.gsub('_',' ').titleize.gsub(' ','') %>Controller < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @<%= table_name %> = <%= class_name %>.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @<%= singular_table_name %> = <%= class_name %>.new
  end

  def edit
  end

  def create
    @<%= singular_table_name %> = <%= class_name %>.new(allowed_params)
    <%- if attributes.map(&:name).include?('user_id') -%>
    @<%= singular_table_name %>.user_id = current_user.id
    <%- elsif attributes.map(&:name).include?('created_by') -%>
    @<%= singular_table_name %>.created_by = current_user.id
    <%- end -%>
    if @<%= singular_table_name %>.save
      flash[:success] = I18n.t('controllers.<%= table_name %>.create.flash.success')
      redirect_to <%= table_name %>_url
    else
      render action: :new
    end
  end

  def update
    <%- if attributes.map(&:name).include?('updated_by') -%>
    params[:<%= singular_table_name -%>][:updated_by] = current_user.id
    <%- end -%>
    if @<%= singular_table_name %>.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.<%= table_name %>.update.flash.success')
      redirect_to <%= table_name %>_url
    else
      render action: :edit
    end
  end

  def destroy
    if @<%= singular_table_name %>.destroy
      flash[:success] = I18n.t('controllers.<%= table_name %>.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.<%= table_name %>.destroy.flash.error')
    end
    redirect_to <%= table_name %>_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @<%= singular_table_name %> = <%= class_name %>.where(id: params[:id]).first
    end
    <%- attributes.each do |attr| -%><%- if attr.name[-3..-1] == '_id' -%>
    @<%= attr.name[0..-4].pluralize %> = <%= attr.name[0..-4].camelcase %>.all_in_order
    <%- end -%><%- end -%>
  end

  def allowed_params
    params.require(:<%= singular_table_name %>).permit(:<%= attributes.map(&:name).join(', :') %>)
  end

end
