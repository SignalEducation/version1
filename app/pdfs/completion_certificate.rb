class CompletionCertificate < Prawn::Document

  def initialize(cert, view)
    super(page_layout: :landscape, page_size: "B5")
    @cert = cert
    @view = view
    logo
    content
  end

  def logo
    logopath =  "#{Rails.root}/app/assets/images/logo_withtext+thin.png"
    image logopath, :width => 650, :height => 100
    move_down 10
  end

  def content
    text "This is to certify that #{@cert.user.full_name} has fulfilled all the requirements for the completion of #{@cert.subject_course.name}"
  end

end