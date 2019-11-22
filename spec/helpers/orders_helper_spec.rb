# frozen_string_literal: true

require 'rails_helper'

describe OrdersHelper do
  let(:order)                   { create(:order) }
  let(:cbe)                     { create(:cbe) }
  let(:cbe_product)             { create(:product, cbe: cbe, product_type: 'cbe') }
  let(:correction_pack_product) { create(:product, cbe: cbe, product_type: 'correction_pack', correction_pack_count: 3) }
  let!(:exercise)               { create(:exercise, product: cbe_product) }
  let(:cbe_order)               { create(:order, product: cbe_product, exercises: [exercise]) }
  let(:correction_pack_order)   { create(:order, product: correction_pack_product) }

  describe '#order_link' do
    context 'returns product link' do
      context 'cbe product' do
        it 'pending exercise' do
          expect(order_link(cbe_order)).to eq("<a target=\"_blank\" href=\"/en/exercises/#{exercise.id}/cbes/#{cbe.id}\">View</a>")
        end

        it 'submitted exercise' do
          exercise.update(state: 'submitted')

          expect(order_link(cbe_order)).to eq("<a target=\"_blank\" href=\"/en/exercises/#{exercise.id}\">View</a>")
        end
      end

      it 'not cbe product' do
        expect(order_link(order)).to eq('<a target="_blank" href="images/missing_image.jpg">View</a>')
      end
    end
  end

  describe '#order_short_description' do
    context 'returns order short description name' do
      it 'mock exam short description' do
        expect(order_short_description(order)).to eq('Purchase an ACCA Mock Exam and increase your chances of passing the ACCA exams.')
      end

      it 'cbe short description' do
        expect(order_short_description(cbe_order)).to eq('Purchase an ACCA CBE and increase your chances of passing the ACCA exams.')
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
        expect(order_description(cbe_order)).to eq('Purchase your CBE today. Once submitted we will give you a solution paper, your result, question by question, personalised feedback on your exam and study topic recommendations.')
      end

      it 'correction pack description' do
        expect(order_description(correction_pack_order)).to eq('This correction pack is applicable to all ACCA courses. Pick and complete any ACCA question from any resource. Once you have submitted your work, our expert tutors will correct it and give you feedback within 3 days.')
      end
    end
  end
end
