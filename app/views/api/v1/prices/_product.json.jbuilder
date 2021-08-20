# frozen_string_literal: true

json.id product.id
json.name product.name
json.stripe_guid product.stripe_guid
json.stripe_sku_guid product.stripe_sku_guid
json.active product.active
json.price number_in_local_currency(product.price, product.currency)
json.product_type product.product_type
json.product_type_name product.name_by_type
json.product_type_url product.url_by_type

json.currency do
  if product.currency.present?
    json.id              product.currency.id
    json.name            product.currency.name
    json.iso_code        product.currency.iso_code
    json.leading_symbol  product.currency.leading_symbol
    json.trailing_symbol product.currency.trailing_symbol
  else
    json.nil!
  end
end

json.cbe do
  if product.cbe_id.present?
    json.id              product.cbe.id
    json.name            product.cbe.name
  else
    json.nil!
  end
end


json.course do
  if product.course_id.present?
    json.id              product.course.id
    json.name            product.course.name
  else
    json.nil!
  end
end
