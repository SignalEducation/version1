class StaticPagesController < ApplicationController

  before_action :logged_in_required, except: :deliver_page
  before_action except: :deliver_page do
    ensure_user_is_of_type(['admin', 'content_manager'])
  end
  before_action :get_variables, except: :deliver_page

  def index
    @static_pages = StaticPage.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
    if params[:preview] == 'yes'
      @delivered_page = @static_page.dup
      @static_page = nil
      if @delivered_page.use_standard_page_template
        render 'static_pages/deliver_page/with_layout'
      else
        render 'static_pages/deliver_page/without_layout', layout: nil
      end
    end
  end

  def new
    @static_page = StaticPage.new(language: 'en', use_standard_page_template: true)
  end

  def edit
  end

  def create
    @static_page = StaticPage.new(narrow_params)
    @static_page.language ||= 'en'
    @static_page.created_by = current_user.id
    if @static_page.save
      if allowed_params[:static_page_uploads_attributes]
        related_upload_ids = allowed_params[:static_page_uploads_attributes].map{|x| x[1][:id] }
        StaticPageUpload.where(id: related_upload_ids).update_all(static_page_id: @static_page.id)
      end
      flash[:success] = I18n.t('controllers.static_pages.create.flash.success')
      if params[:commit] == I18n.t('views.general.save_and_continue_editing')
        render action: :edit
      else
        redirect_to static_pages_url
      end
    else
      render action: :new
    end
  end

  def update
    if @static_page.update_attributes(allowed_params.merge({updated_by: current_user.id}))
      flash[:success] = I18n.t('controllers.static_pages.update.flash.success')
      if params[:commit] == I18n.t('views.general.save_and_continue_editing')
        render action: :edit
      else
        redirect_to static_pages_url
      end
    else
      render action: :edit
    end
  end

  def deliver_page
    if params[:first_element].to_s == '' && current_user
      redirect_to dashboard_url
    elsif params[:first_element].to_s == '500-page'
      render 'public/500.html', layout: nil, status: 500
    else
      first_element = '/' + params[:first_element].to_s
      @delivered_page = StaticPage.all_for_language(params[:locale]).all_active.with_logged_in_status(current_user).where(public_url: first_element).sample
      if @delivered_page
        if @delivered_page.use_standard_page_template
          render 'static_pages/deliver_page/with_layout'
        else
          render 'static_pages/deliver_page/without_layout', layout: nil
        end
      else
        render 'static_pages/deliver_page/404_page.html.haml', status: 404
      end
    end
  end

  def destroy
    if @static_page.destroy
      flash[:success] = I18n.t('controllers.static_pages.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.static_pages.destroy.flash.error')
    end
    redirect_to static_pages_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @static_page = StaticPage.where(id: params[:id]).first
      @static_page_uploads = StaticPageUpload.orphans_or_for_page(@static_page.id)
    else
      @static_page_uploads = StaticPageUpload.orphans.all_in_order
    end
    seo_title_maker(@static_page.try(:name))
    @countries = Country.all_in_order
    @samples = sample_code
  end

  def allowed_params
    params.require(:static_page).permit(
            :name,
            :publish_from, :publish_to,
            :allow_multiples,
            :public_url,
            :use_standard_page_template,
            :head_content,
            :body_content,
            :add_to_navbar,
            :add_to_footer,
            :menu_label,
            :tooltip_text,
            :language,
            :mark_as_noindex, :mark_as_nofollow,
            :seo_title, :seo_description,
            :default_page_for_this_url,
            :make_this_page_sticky,
            :logged_in_required,
            :created_by, :updated_by,
            static_page_uploads_attributes: [
                    :id,
                    :description,
                    :static_page_id,
                    :upload
            ],
            :approved_country_ids => [])
  end

  def narrow_params
    # no nested params for static_page_uploads
    params.require(:static_page).permit(
            :name,
            :publish_from, :publish_to,
            :allow_multiples,
            :public_url,
            :use_standard_page_template,
            :head_content,
            :body_content,
            :add_to_navbar,
            :add_to_footer,
            :menu_label,
            :tooltip_text,
            :language,
            :mark_as_noindex, :mark_as_nofollow,
            :seo_title, :seo_description,
            :default_page_for_this_url,
            :make_this_page_sticky,
            :logged_in_required,
            :created_by, :updated_by,
            :approved_country_ids => [])
  end

  def sample_code
    [
            {name: 'Transparent navbar',
             code: '
<nav class="navbar navbar-transparent navbar-default navbar-fixed-top">
  <div class="container">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="#">Project name</a>
    </div>
    <div id="navbar" class="navbar-collapse collapse">
      <ul class="nav navbar-nav">
        <li class="active"><a href="#">Home</a></li>
        <li><a href="#about">About</a></li>
        <li><a href="#contact">Contact</a></li>
      </ul>
      <ul class="nav navbar-nav navbar-right">
        <li><a href="/sign_in">Sign in</a></li>
        <li><a href="/student_sign_up">Sign up</a></li>
      </ul>
    </div>
  </div>
</nav>
'
            },
            {name: 'Image & header',
             code: '
<header style="background-image: url(http://learnsignal3-dev-dan.s3-eu-west-1.amazonaws.com/static_page_uploads/148/Coca-Cola-1179x1181.jpg?1420559789);">
  <div class="container">
    <div class="intro-text">
      <div class="intro-heading hidden-xs">Pass your professional exams</div>
      <div class="intro-heading visible-xs">Pass your exams</div>
      <div class="intro-lead-in">The Home of CFA</div>
      <a href="/library" class="page-scroll btn btn-xl">Browse Courses</a>
      <a href="/user_signups/new" class="page-scroll btn btn-xl">Start Free Trial</a>
    </div>
  </div>
</header>
'
            },
            {name: 'Image carousel',
             code: '
<div id="myCarousel" class="carousel slide" data-ride="carousel">
  <ol class="carousel-indicators">
    <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
    <li data-target="#myCarousel" data-slide-to="1"></li>
    <li data-target="#myCarousel" data-slide-to="2"></li>
  </ol>
  <div class="carousel-inner" role="listbox">
    <div class="item active">
      <img src="http://learnsignal3-dev-dan.s3-eu-west-1.amazonaws.com/static_page_uploads/148/Coca-Cola-1179x1181.jpg?1420559789" alt="First slide" class="img-responsive">
      <div class="container">
        <div class="carousel-caption">
          <h1>Example headline.</h1>
          <p>Note: If you\'re viewing this page via a <code>file://</code> URL, the "next" and "previous" Glyphicon buttons on the left and right might not load/display properly due to web browser security rules.</p>
          <p><a class="btn btn-lg btn-primary" href="#" role="button">Sign up today</a></p>
        </div>
      </div>
    </div>
    <div class="item">
      <img src="http://learnsignal3-dev-dan.s3-eu-west-1.amazonaws.com/static_page_uploads/148/Coca-Cola-1179x1181.jpg?1420559789" alt="Second slide">
      <div class="container">
        <div class="carousel-caption">
          <h1>Another example headline.</h1>
          <p>Cras justo odio, dapibus ac facilisis in, egestas eget quam. Donec id elit non mi porta gravida at eget metus. Nullam id dolor id nibh ultricies vehicula ut id elit.</p>
          <p><a class="btn btn-lg btn-primary" href="#" role="button">Learn more</a></p>
        </div>
      </div>
    </div>
    <div class="item">
      <img src="http://learnsignal3-dev-dan.s3-eu-west-1.amazonaws.com/static_page_uploads/148/Coca-Cola-1179x1181.jpg?1420559789" alt="Third slide">
      <div class="container">
        <div class="carousel-caption">
          <h1>One more for good measure.</h1>
          <p>Cras justo odio, dapibus ac facilisis in, egestas eget quam. Donec id elit non mi porta gravida at eget metus. Nullam id dolor id nibh ultricies vehicula ut id elit.</p>
          <p><a class="btn btn-lg btn-primary" href="#" role="button">Browse gallery</a></p>
        </div>
      </div>
    </div>
  </div>
    <a class="left carousel-control" href="#myCarousel" role="button" data-slide="prev">
    <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
    <span class="sr-only">Previous</span>
    </a>
  <a class="right carousel-control" href="#myCarousel" role="button" data-slide="next">
    <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
    <span class="sr-only">Next</span>
  </a>
</div>
'
            },
            {name: 'Four boxes',
             code: '
<div class="container">
  <div class="row">
    <div class="col-sm-3">
      <img src="http://learnsignal3-dev-dan.s3-eu-west-1.amazonaws.com/static_page_uploads/148/Coca-Cola-1179x1181.jpg?1420559789" alt="First slide" class="img-responsive">
      <h3>Mary Had A Little Lamb</h3>
      <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.</p>
      <a href="/mary" class="btn btn-default">Learn More...</a>
    </div>
    <div class="col-sm-3">
      <img src="http://learnsignal3-dev-dan.s3-eu-west-1.amazonaws.com/static_page_uploads/148/Coca-Cola-1179x1181.jpg?1420559789" alt="First slide" class="img-responsive">
      <h3>Baah Baah Black Sheep</h3>
      <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.</p>
      <a href="/mary" class="btn btn-default">Learn More...</a>
    </div>
    <div class="col-sm-3">
      <img src="http://learnsignal3-dev-dan.s3-eu-west-1.amazonaws.com/static_page_uploads/148/Coca-Cola-1179x1181.jpg?1420559789" alt="First slide" class="img-responsive">
      <h3>Itsy Bitsy Spider</h3>
      <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.</p>
      <a href="/mary" class="btn btn-default">Learn More...</a>
    </div>
    <div class="col-sm-3">
      <img src="http://learnsignal3-dev-dan.s3-eu-west-1.amazonaws.com/static_page_uploads/148/Coca-Cola-1179x1181.jpg?1420559789" alt="First slide" class="img-responsive">
      <h3>Peter Piper Had a Peck of Pickled Peppers</h3>
      <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.</p>
      <a href="/mary" class="btn btn-default">Learn More...</a>
    </div>
  </div>
</div>
'}
    ]
  end
end
