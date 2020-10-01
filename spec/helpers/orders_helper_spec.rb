# frozen_string_literal: true

require 'rails_helper'

describe OrdersHelper, type: :helper do
  let(:order)                   { create(:order) }
  let(:cbe)                     { create(:cbe) }
  let(:cbe_product)             { create(:product, cbe: cbe, product_type: 'cbe') }
  let(:correction_pack_product) { create(:product, cbe: cbe, product_type: 'correction_pack', correction_pack_count: 3) }
  let!(:exercise)               { create(:exercise, product: cbe_product) }
  let(:cbe_order)               { create(:order, product: cbe_product, exercises: [exercise]) }
  let(:correction_pack_order)   { create(:order, product: correction_pack_product) }
  let(:custom_product)          { create(:product, payment_heading: 'The custom product', payment_subheading: 'Custom product subheading', payment_description: 'Custom product description') }
  let(:custom_order)            { create(:order, product: custom_product) }
  let(:lifetime_product)        { create(:product, product_type: 'lifetime_access') }
  let(:lifetime_order)          { build(:order, product: lifetime_product) }

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

  describe '#order_heading' do
    context 'returns order heading' do
      it 'mock exam order heading' do
        expect(order_heading(order)).to eq("#{order.product.name_by_type} Purchase")
      end

      it 'cbe order heading' do
        expect(order_heading(cbe_order)).to eq("#{cbe.name} Purchase")
      end

      it 'correction pack order heading' do
        expect(order_heading(correction_pack_order)).to eq("#{order.product.name_by_type} Purchase")
      end

      it 'custom order heading' do
        expect(order_heading(custom_order)).to eq('The custom product')
      end
    end
  end

  describe '#order_short_description' do
    context 'returns order short description name' do
      it 'mock exam short description' do
        expect(order_short_description(order)).to eq('Purchase a Mock Exam and increase your chances of passing the your exams.')
      end

      it 'cbe short description' do
        expect(order_short_description(cbe_order)).to eq('Purchase a CBE and increase your chances of passing your exams.')
      end

      it 'correction pack short description' do
        expect(order_short_description(correction_pack_order)).to eq('Pass your exams faster with a question and solution correction pack.')
      end

      it 'lifetime order short description' do
        expect(order_short_description(lifetime_order)).to eq("One-time Payment - Instant Access to all #{lifetime_product.group.name} Courses")
      end

      it 'custom order short description' do
        expect(order_short_description(custom_order)).to eq('Custom product subheading')
      end
    end
  end

  describe '#order_description' do
    context 'returns order description name' do
      it 'mock exam description' do
        expect(order_description(order)).to eq('Purchase your Mock Exam today. Once submitted we will give you a solution paper, your result, question by question, personalised feedback on your exam and study topic recommendations within 3 days.')
      end

      it 'cbe description' do
        expect(order_description(cbe_order)).to eq('Purchase your CBE today to start practicing for your online exam by simulating the computer based exam on the learnsignal site.')
      end

      it 'correction pack description' do
        expect(order_description(correction_pack_order)).to eq('This correction pack is applicable to all courses. Pick and complete any question from any resource. Once you have submitted your work, our expert tutors will correct it and give you feedback within 3 days.')
      end

      it 'lifetime order description' do
        expect(order_description(lifetime_order)).to eq("Enjoy incredible savings and unlock Lifetime access to ACCA tuition for every #{lifetime_product.group.name} exam. Get all the #{lifetime_product.group.name} tuition you need to pass every #{lifetime_product.group.name} exam on your journey to becoming fully qualified for just one single fee. Learnsignal Lifetime Members can access tuition and study materials for every #{lifetime_product.group.name} course and never worry about paying for exam tuition again.")
      end

      it 'custom order description' do
        expect(order_description(custom_order)).to eq('Custom product description')
      end
    end
  end
end
