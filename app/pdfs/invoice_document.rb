# frozen_string_literal: true

class InvoiceDocument < Prawn::Document
  include InvoicesHelper

  attr_reader :invoice, :vat_rate

  def initialize(invoice)
    super(top_margin: 70)
    @invoice  = invoice
    @vat_rate = invoice.vat_rate ? @invoice.vat_rate.percentage_rate.to_s + '%' : '0%'

    logo
    render_headers
    render_details
    render_summary
    footer
  end

  def logo
    logopath   = Rails.root.join('app', 'assets', 'images', 'learnsignal_mark_RGB.png')
    y_position = cursor

    image logopath, width: 40, height: 40, at: [0, y_position]
  end

  def render_headers
    move_down 100
    table([['Invoice Receipt']], width: 540, cell_style: { padding: 0 }) do
      row(0..10).borders = []
      cells.column(0).style(size: 20, font_style: :bold, valign: :center)
    end
  end

  # Renders details about pdf. Shows recipient name, invoice date and id
  def render_details
    move_down 10
    stroke_horizontal_rule
    move_down 35

    billing_details =
      make_table([['Billed to:'], [recipient_name]], width: 355, cell_style: { padding: 0 }) do
        row(0..10).style(size: 9, borders: [])
        row(0).column(0).style(font_style: :bold)
      end

    invoice_date    = invoice.issued_at.strftime('%e %b %Y')
    invoice_id      = invoice.id.to_s
    invoice_details =
      make_table([['Invoice Date:', invoice_date], ['Invoice No:', invoice_id]], width: 185, cell_style: { padding: 5, border_width: 0.5 }) do
        row(0..10).style(size: 9)
        row(0..10).column(0).style(font_style: :bold)
      end

    table([[billing_details, invoice_details]], cell_style: { padding: 0 }) do
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

    table_details = [['No.', 'Description', 'VAT', 'Total Price']]
    invoice.invoice_line_items.each_with_index do |line_item, index|
      table_details << [index + 1,
                        pdf_description(invoice, line_item),
                        item_vat_rate(vat_rate, line_item),
                        line_item.amount]
    end

    table(table_details, column_widths: [40, 380, 60, 60], header: true,
          cell_style: { padding: 5, border_width: 0.5 }) do
      row(0).style(size: 10, font_style: :bold)
      row(0..100).style(size: 9)

      cells.columns(0).align = :right
      cells.columns(2).align = :right
      cells.columns(3).align = :right
      row(0..100).borders    = [:top, :bottom]
    end

    summary_details = [
      ['Subtotal', invoice.currency.format_number(invoice.sub_total)],
      ['Discount', invoice.currency.format_number((invoice.sub_total - invoice.total))],
      ['Total',    invoice.currency.format_number(invoice.total)]
    ]

    table(summary_details, column_widths: [480, 60], header: true,
          cell_style: { padding: 5, border_width: 0.5 }) do
      row(0..100).style(size: 9, font_style: :bold)
      row(0..100).borders = []
      cells.columns(0..100).align = :right
    end

    move_down 25
  end

  def footer
    move_down 250
    stroke_horizontal_rule
    stroke_horizontal_rule
    move_down 25
    text "Signal Education Limited t/a LearnSignal, Fleming Court, Fleming's Place, Dublin, D04 N4X9, Ireland", size: 10, align: :center
    text 'email: info@learnsignal.com   phone: +353 1 443 4575', size: 10, align: :center
    text 'VAT Number: IE3313351FH', size: 10, align: :center
  end

  def recipient_name
    I18n.transliterate(invoice.user.full_name)
  end
end
