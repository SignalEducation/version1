# frozen_string_literal: true

module ProductsHelper
  def product_link(product, current_user)
    return new_product_order_url(product.id) if current_user

    id = product.cbe? ? product.cbe.subject_course.exam_body.id : product.mock_exam.subject_course.group.exam_body.id
    sign_in_or_register_url(exam_body_id: id, product_id: product.id)
  end

  def product_icon(product)
    if product.cbe?
      tag.i class: 'budicon-desktop', role: 'img'
    elsif product.product_type == 'correction_pack'
      tag.i class: 'budicon-files-tick', role: 'img'
    else
      tag.i class: 'budicon-file-tick', role: 'img'
    end
  end
end
