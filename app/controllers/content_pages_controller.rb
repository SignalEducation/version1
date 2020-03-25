# frozen_string_literal: true

class ContentPagesController < ApplicationController
  before_action :logged_in_required, except: [:show]
  before_action except: [:show] do
    ensure_user_has_access_rights(%w[system_requirements_access marketing_resources_access])
  end
  before_action :set_content_page, except: :show
  before_action :management_layout, except: :show

  def index
    @content_pages = ContentPage.all_in_order
  end

  def show
    @content_page = ContentPage.where(public_url: params[:content_public_url]).first
    if @content_page&.active
      seo_title_maker(@content_page.seo_title, @content_page.seo_description, nil)
      @navbar = true
      @top_margin = true
      @footer = true

    else
      redirect_to root_url
    end
  end

  def new
    if params[:bootcamp_page]
      @group = Group.all_active.all_in_order.first
      @courses = @group.active_children.all_in_order
      text_content = "<p><b>Signing up to the LearnSignal is the first step in passing your next ACCA exam.</b></p><p>The Exam Bootcamp has been designed with our students in mind. We enjoy the fact that if you are not our student that you feel you are benefitting from the daily email prompt. However, to get access to all of the amazing resources offered in the Exam Bootcamp and on our learning platform then<span>&nbsp;</span><b><a href='#{new_student_url}' target='_blank'>join LearnSignal now</a></b><span>.</span></p><p><b>Now, let’s get started!</b></p><p><b>1. Scroll down to your subject, find out your topic and go straight to your course</b></p><p><b>2. Review the lectures and notes before attempting the question</b></p><p><b>3. Do it under exam conditions (that means timed!!) and use the CBE tool when applicable</b></p><p><b>4. Review your attempt against the tutor solution and correct it as you go</b></p>"

      @content_page = ContentPage.new(text_content: text_content)
      @courses.reverse.each_with_index do |course, index|
        text = "<h3>#{course.name}</h3><p style="">TODAY'S TOPIC IS <b>Professional and Ethical Considerations</b>&nbsp;- CLICK HERE TO GO TO YOUR COURSE PAGE AND ATTEMPT&nbsp;the <b>yes</b>&nbsp;</b><span>question</span>. remember TO MARK YOURSELF AGAINST THE TUTOR SOLUTION PROVIDED.<br></p>"

        @content_page.content_page_sections.build(text_content: text,
                                                  course_id: course.id,
                                                  sorting_order: index + 1,
                                                  panel_colour: course.highlight_colour)
      end

    else
      @content_page = ContentPage.new
    end
  end

  def edit
    @content_page.content_page_sections.build if params[:bootcamp_page]
  end

  def create
    @content_page = ContentPage.new(allowed_params)

    if @content_page.save
      flash[:success] = I18n.t('controllers.content_pages.create.flash.success')
      redirect_to content_pages_url
    else
      render action: :new
    end
  end

  def update
    if @content_page.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.content_pages.update.flash.success')
      redirect_to content_pages_url
    else
      render action: :edit
    end
  end

  def destroy
    if @content_page.destroy
      flash[:success] = I18n.t('controllers.content_pages.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.content_pages.destroy.flash.error')
    end

    redirect_to content_pages_url
  end

  protected

  def set_content_page
    @content_page = ContentPage.find_by(id: params[:id])
  end

  def allowed_params
    params.require(:content_page).permit(:name, :public_url, :seo_title, :seo_description, :text_content,
                                         :h1_text, :h1_subtext, :footer_link, :active,
                                         content_page_sections_attributes: [:id, :text_content,
                                                                            :panel_colour,
                                                                            :sorting_order,
                                                                            :course_id, :_destroy])
  end
end
