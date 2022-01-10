# frozen_string_literal: true

require 'rails_helper'

describe ProductsHelper, type: :helper do
  let(:cbe)                     { create(:cbe) }
  let(:cbe_product)             { create(:product, cbe: cbe, product_type: 'cbe') }
  let(:correction_pack_product) { create(:product, cbe: cbe, product_type: 'correction_pack', correction_pack_count: 3) }
  let(:lifetime_product)        { create(:product, product_type: 'lifetime_access') }
  let(:course_product)          { create(:product, product_type: 'program_access') }

  describe '#product_link' do
    context 'returns product link to a logged user' do
      it 'cbe product' do
        expect(product_link(cbe_product, true)).to include("products/#{cbe_product.id}/orders/new")
      end

      it 'not cbe product' do
        expect(product_link(correction_pack_product, true)).to include("products/#{correction_pack_product.id}/orders/new")
      end

      it 'lifetime product' do
        expect(product_link(lifetime_product, true)).to include("products/#{lifetime_product.id}/orders/new")
      end

      it 'course product' do
        expect(product_link(course_product, true)).to include("products/#{course_product.id}/orders/new")
      end
    end

    context 'returns product link to a not logged user' do
      it 'cbe product' do
        exam_body_id = cbe_product.cbe.course.exam_body.id
        expect(product_link(cbe_product, false)).to include("register_or_login?exam_body_id=#{exam_body_id}&product_id=#{cbe_product.id}")
      end

      it 'not cbe product' do
        exam_body_id = correction_pack_product.mock_exam.course.group.exam_body.id
        expect(product_link(correction_pack_product, false)).to include("register_or_login?exam_body_id=#{exam_body_id}&product_id=#{correction_pack_product.id}")
      end
    end
  end
end
