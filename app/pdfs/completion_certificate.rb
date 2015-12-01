class CompletionCertificate < Prawn::Document

  def initialize(cert, view)
    super(page_layout: :landscape, page_size: [560, 852], background: "#{Rails.root}/app/assets/images/cert_background.png", :margin => [20, 100])
    @cert = cert
    @view = view
    logo
    line_1
    user_name
    line_2
    course_name
    date
    signature
  end

  def logo
    move_down 80
    logopath =  "#{Rails.root}/app/assets/images/logo_withtext+thin.png"
    y_position = cursor
    image logopath, :width => 250, :height => 40, at: [200, y_position]
  end

  def line_1
    move_down 112
    font_size 16
    text "This is to certify that", align: :center, style: :italic
  end

  def user_name
    move_down 17
    font_size 24
    #text "#{@cert.user.full_name}", align: :center
    text "Johnny Meagher", align: :center
  end

  def line_2
    move_down 20
    font_size 16
    text "has fulfilled all the requirements for the completion of", align: :center, style: :italic
  end

  def course_name
    move_down 20
    font_size 24
    #text "#{@cert.subject_course.name}", align: :center
    text "Risk Management in Investment Management", align: :center
  end

  def date
    move_down 75
    font_size 10
    y_position = cursor
    #draw_text "Date issued: #{@cert.completion_certificate.created_at}", at: [60, y_position]

  end

  def signature
    font_size 10
    y_position = cursor
    draw_text "Philip Meagher - CEO at LearnSignal", at: [430, y_position]
  end
end