class MarketingTokensController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @marketing_tokens = MarketingToken.includes(:marketing_category).paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @marketing_token = MarketingToken.new
  end

  def edit
    redirect_to marketing_tokens_url unless @marketing_token.editable?
  end

  def create
    @marketing_token = MarketingToken.new(allowed_params)
    if @marketing_token.save
      flash[:success] = I18n.t('controllers.marketing_tokens.create.flash.success')
      redirect_to marketing_tokens_url
    else
      render action: :new
    end
  end

  def update
    if !@marketing_token.editable?
      flash[:error] = I18n.t('controllers.marketing_tokens.update.flash.error')
      redirect_to marketing_tokens_url
    elsif @marketing_token.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.marketing_tokens.update.flash.success')
      redirect_to marketing_tokens_url
    else
      render action: :edit
    end
  end

  def destroy
    if @marketing_token.destroy
      flash[:success] = I18n.t('controllers.marketing_tokens.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.marketing_tokens.destroy.flash.error')
    end
    redirect_to marketing_tokens_url
  end

  def preview_csv
    @csv_data, @has_errors = MarketingToken.parse_csv(params[:upload].read) if params[:upload] && params[:upload].respond_to?(:read)
  end

  def import_csv
    @tokens = MarketingToken.bulk_create(params[:csvdata])
  end

  def download_csv
    tokens_csv = MarketingToken.includes(:marketing_category).where('code not in (?)', MarketingToken::SYSTEM_TOKEN_CODES).map do |token|
      "#{token.code},#{token.marketing_category.name},#{token.is_hard}"
    end.join("\n")

    send_data tokens_csv, filename: 'MarketingTokens.csv', type: 'text/csv'
  end

  protected

  def get_variables
    @marketing_categories = MarketingCategory.all_in_order
    if params[:id].to_i > 0
      @marketing_token = MarketingToken.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:marketing_token).permit(:code, :marketing_category_id, :is_hard)
  end

end
