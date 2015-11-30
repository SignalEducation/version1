class CompletionCertificate < Prawn::Document

  def initialize(cert, view)
    super(page_layout: :landscape, page_size: [560, 834], background: "#{Rails.root}/app/assets/images/cert_background.png", :margin => [20, 100])
    @cert = cert
    @view = view
    user_name
    course_name
  end

  def logo
    logopath =  "#{Rails.root}/app/assets/images/logo_withtext+thin.png"
    image logopath, :width => 650, :height => 100
    move_down 10
  end

  def user_name
    text_box "#{@cert.user.full_name}", at: [280, 290], height: 20, width: 200, align: :center
  end

  def course_name
    text_box "#{@cert.subject_course.name}", at: [280, 200], height: 20, width: 200, align: :center
  end

end