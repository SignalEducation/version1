# frozen_string_literal: true

require 'rails_helper'

describe OrdersHelper do
  let(:order)                   { build(:order) }
  let(:cbe)                     { create(:cbe) }
  let(:cbe_product)             { create(:product, cbe: cbe, product_type: 'cbe') }
  let(:correction_pack_product) { create(:product, cbe: cbe, product_type: 'correction_pack', correction_pack_count: 3) }
  let(:cbe_order)               { build(:order, product: cbe_product) }
  let(:correction_pack_order)   { build(:order, product: correction_pack_product) }

  describe '#order_name' do
    context 'returns product name' do
      it 'cbe product' do
        expect(order_name(cbe_order)).to eq("#{cbe_order.product.cbe.name} Purchase")
      end

      it 'not cbe product' do
        expect(order_name(order)).to eq("#{order.product.mock_exam.name} Purchase")
      end
    end
  end

  describe '#order_short_description' do
    context 'returns order short description name' do
      it 'mock exam short description' do
        expect(order_short_description(order)).to eq('Purchase an ACCA Mock Exam and increase your chances of passing the ACCA exams.')
      end

      it 'cbe short description' do
        expect(order_short_description(cbe_order)).to eq('WE NEED A SHORT DESCRIPTION HERE - - WE NEED A SHORT DESCRIPTION HERE - - WE NEED A SHORT DESCRIPTION HERE')
      end

      it 'correction pack short description' do
        expect(order_short_description(correction_pack_order)).to eq('Pass your ACCA exams faster with a question and solution correction pack.')
      end
    end
  end

  describe '#order_description' do
    context 'returns order description name' do
      it 'mock exam description' do
        expect(order_description(order)).to eq('Purchase your Mock Exam today. Once submitted we will give you a solution paper, your result, question by question, personalised feedback on your exam and study topic recommendations.')
      end

      it 'cbe description' do
        expect(order_description(cbe_order)).to eq('WE NEED A DESCRIPTION HERE - - WE NEED A DESCRIPTION HERE  - - WE NEED A DESCRIPTION HERE')
      end

      it 'correction pack description' do
        expect(order_description(correction_pack_order)).to eq('This correction pack is applicable to all ACCA courses. Pick and complete any ACCA question from any resource. Once you have submitted your work, our expert tutors will correct it and give you feedback within 3 days.')
      end
    end
  end
end
