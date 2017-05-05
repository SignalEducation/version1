class InvoiceDocument < Prawn::Document

  def initialize(inv, view, description, vat_rate, invoice_date)
    super(top_margin: 70)
    @invoice = inv
    @view = view
    @description = description
    @vat_rate = vat_rate
    @invoice_date = invoice_date
    logo
    move_down 100
    render_headers
    render_details
    render_summary
    move_down 250
    stroke_horizontal_rule
    footer

  end

  def render_headers
    table([ ['Invoice Receipt'] ], width: 540, cell_style: {padding: 0}) do
      row(0..10).borders = []
      cells.column(0).style(size: 20, font_style: :bold, valign: :center)
    end
  end

  # Renders details about pdf. Shows recipient name, invoice date and id
  def render_details
    move_down 10
    stroke_horizontal_rule
    move_down 15

    billing_details =
        make_table([ ['Billed to:'], [recipient_name] ],
                       width: 355, cell_style: {padding: 0}) do
          row(0..10).style(size: 9, borders: [])
          row(0).column(0).style(font_style: :bold)
        end

    invoice_date = @invoice_date.strftime('%e %b %Y')
    invoice_id   = @invoice.id.to_s
    invoice_details =
        make_table([ ['Invoice Date:', invoice_date], ['Invoice No:', invoice_id] ],
                       width: 185, cell_style: {padding: 5, border_width: 0.5}) do
          row(0..10).style(size: 9)
          row(0..10).column(0).style(font_style: :bold)
        end

    table([ [billing_details, invoice_details] ], cell_style: {padding: 0}) do
      row(0..10).style(borders: [])
    end
  end

  # Renders details of invoice in a tabular format. Renders each line item, and
  # unit price, and total amount, along with tax. It also displays summary,
  # ie total amount, and total price along with tax.
  def render_summary
    move_down 25
    text 'Invoice Summary', size: 12, style: :bold
    stroke_horizontal_rule

    table_details = [ ['No.', 'Description', 'VAT', 'Total Price'] ]
    @invoice.invoice_line_items.each_with_index do |line_item, index|
      net_amount = line_item.amount
      table_details <<
          [index + 1, @description, @vat_rate, net_amount]
    end
    table(table_details, column_widths: [40, 380, 60, 60], header: true,
              cell_style: {padding: 5, border_width: 0.5}) do
      row(0).style(size: 10, font_style: :bold)
      row(0..100).style(size: 9)

      cells.columns(0).align = :right
      cells.columns(2).align = :right
      cells.columns(3).align = :right
      row(0..100).borders = [:top, :bottom]
    end

    summary_details = [
        ['Subtotal', @invoice.currency.format_number(@invoice.sub_total)],
        ['Discount', @invoice.currency.format_number((@invoice.sub_total - @invoice.total))],
        ['Total',    @invoice.currency.format_number(@invoice.total)]
    ]
    table(summary_details, column_widths: [480, 60], header: true,
              cell_style: {padding: 5, border_width: 0.5}) do
      row(0..100).style(size: 9, font_style: :bold)
      row(0..100).borders = []
      cells.columns(0..100).align = :right
    end

    move_down 25
  end

  def recipient_name
    @invoice.user.full_name
  end

  def logo
    logopath =  "#{Rails.root}/app/assets/images/logo_withtext+thin.png"
    y_position = cursor
    image logopath, width: 275, height: 40, at: [0, y_position]
  end

  def footer
    stroke_horizontal_rule
    move_down 25
    text 'Signal Education Limited t/a LearnSignal, 18-20 Merrion Street Upper Dublin 2, Ireland', size: 10, align: :center
    text 'email: info@learnsignal.com   phone: +353 1 4428581', size: 10, align: :center
    text 'VAT Number: IE3313351FH', size: 10, align: :center
  end

end