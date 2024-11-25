# frozen_string_literal: true

require 'rails_helper'

describe InvoicesHelper, type: :helper do
  let(:subscription_plan)        { build(:subscription_plan) }
  let(:subscription)             { build(:subscription, subscription_plan: subscription_plan) }
  let(:invoice)                  { build(:invoice, subscription: subscription) }
  let(:invoice_line_item)        { build(:invoice_line_item, invoice: invoice, subscription: subscription, subscription_plan_id: subscription_plan) }
  let(:cbe)                      { build(:cbe) }
  let(:cbe_product)              { build(:product, cbe: cbe, product_type: 'cbe') }
  let(:mock_exam_product)        { build(:product, cbe: cbe, product_type: 'mock_exam', correction_pack_count: 3) }
  let(:lifetime_product)         { create(:product, product_type: 'lifetime_access') }
  let(:cbe_order)                { build(:order, product: cbe_product) }
  let(:mock_exam_order)          { build(:order, product: mock_exam_product) }
  let(:lifetime_order)           { build(:order, product: lifetime_product) }

  describe 'Methods' do
    it '#invoice_type' do
      expect(invoice_type(invoice)).to eq('Order')
    end

    it '#item_vat_rate' do
      expect(item_vat_rate(20, invoice_line_item)).to eq(20)
    end

    describe '#pdf_description' do
      context 'subscription' do
        it 'subscription' do
          allow_any_instance_of(InvoicesHelper).to receive(:subscription?).and_return(true)

          expect(pdf_description(invoice, invoice_line_item)).to eq("#{subscription_plan.exam_body.name} Monthly Subscription")
        end

        it 'mock_exam' do
          invoice.order = mock_exam_order
          expect(pdf_description(invoice, invoice_line_item)).to eq('MyString')
        end

        it 'cbe' do
          invoice.order = cbe_order
          expect(pdf_description(invoice, invoice_line_item)).to eq(cbe.name)
        end

        it 'lifetime_access' do
          invoice.order = lifetime_order
          expect(pdf_description(invoice, invoice_line_item)).to eq(lifetime_product.name)
        end
      end
    end
  end
end
