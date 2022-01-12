# frozen_string_literal: true

module ProductsHelper
  def product_link(product, current_user = nil, login = nil)
    return new_product_order_url(product.id) if current_user

    exam_body_id =
      if product.cbe?
        product.cbe.course.exam_body.id
      elsif product.product_type == 'correction_pack'
        product.mock_exam.course.group.exam_body.id
      elsif product.product_type == 'lifetime_access'
        group = Group.find_by(id: product.group_id)
        group.exam_body.id
      elsif product.course
        product.course.group.exam_body.id
      else
        product.mock_exam.course.group.exam_body.id
      end

    login ? sign_in_checkout_url(exam_body_id: exam_body_id, product_id: product.id) : sign_in_or_register_url(exam_body_id: exam_body_id, product_id: product.id)
  end

  def product_icon(product)
    if product.cbe?
      tag.i class: 'budicon-desktop', role: 'img', style: 'font-size: 4rem;'
    elsif product.product_type == 'correction_pack'
      tag.i class: 'budicon-files-tick', role: 'img', style: 'font-size: 4rem;'
    elsif product.product_type == 'lifetime_access'
      tag.i class: 'budicon-web-banking', role: 'img', style: 'font-size: 4rem;'
    elsif product.product_type == 'program_access'
      tag.i class: product.course.icon_label, role: 'img'
    else
      tag.i class: 'budicon-file-tick', role: 'img', style: 'font-size: 4rem;'
    end
  end
end
