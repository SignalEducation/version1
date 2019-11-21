# frozen_string_literal: true

require 'rails_helper'

describe ProductsHelper do
  let(:cbe)                     { create(:cbe) }
  let(:cbe_product)             { create(:product, cbe: cbe, product_type: 'cbe') }
  let(:correction_pack_product) { create(:product, cbe: cbe, product_type: 'correction_pack', correction_pack_count: 3) }

  describe '#product_name' do
    context 'returns product name' do
      it 'cbe product' do
        expect(product_name(cbe_product)).to eq("#{cbe_product.cbe.name} Purchase")
      end

      it 'not cbe product' do
        expect(product_name(correction_pack_product)).to eq("#{cbe_product.mock_exam.name} Purchase")
      end
    end
  end

  describe '#product_link' do
    context 'returns product link to a logged user' do
      it 'cbe product' do
        expect(product_link(cbe_product, true)).to include("products/#{cbe_product.id}/orders/new")
      end

      it 'not cbe product' do
        expect(product_link(correction_pack_product, true)).to include("products/#{correction_pack_product.id}/orders/new")
      end
    end

    context 'returns product link to a not logged user' do
      it 'cbe product' do
        exam_body_id = cbe_product.cbe.subject_course.exam_body.id
        expect(product_link(cbe_product, false)).to include("register_or_login?exam_body_id=#{exam_body_id}&product_id=#{cbe_product.id}")
      end

      it 'not cbe product' do
        exam_body_id = correction_pack_product.mock_exam.subject_course.group.exam_body.id
        expect(product_link(correction_pack_product, false)).to include("register_or_login?exam_body_id=#{exam_body_id}&product_id=#{correction_pack_product.id}")
      end
    end
  end

  describe '#product_icon' do
    context 'returns product ico' do
      it 'cbe product' do
        expect(product_icon(cbe_product)).to eq('<i class="budicon-desktop" role="img"></i>')
      end

      it 'not cbe product' do
        expect(product_icon(correction_pack_product)).to eq('<i class="budicon-files-tick" role="img"></i>')
      end
    end
  end
end
