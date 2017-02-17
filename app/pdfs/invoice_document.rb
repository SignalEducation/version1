class InvoiceDocument < Prawn::Document

  def initialize(inv, view)
    super(page_layout: :portrait)
    @inv = inv
    @view = view
    logo
    line_1
    user_name
    line_2
  end

  def logo
    move_down 95
    logopath =  "#{Rails.root}/app/assets/images/logo_withtext+thin.png"
    y_position = cursor
    image logopath, width: 275, height: 40, at: [200, y_position]
  end

  def line_1
    move_down 95
    font_size 16
    text "This is to certify that", align: :center, style: :italic
  end

  def user_name
    move_down 17
    font_size 24
    text "#{@inv.user.full_name}", align: :center
  end

  def line_2
    move_down 20
    font_size 16
    text "has fulfilled all the requirements for the completion of", align: :center, style: :italic
  end


end