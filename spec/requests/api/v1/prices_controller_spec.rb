# frozen_string_literal: true

require 'rails_helper'
require 'support/system_setup'

RSpec.describe Api::V1::PricesController, type: :request do
  before do
    allow_any_instance_of(StripePlanService).to receive(:create_plan).and_return(true)
    allow_any_instance_of(PaypalPlansService).to receive(:create_plan).and_return(true)
  end

  include_context 'system_setup'
  let!(:active_bearer) { create(:bearer, :active) }


  # index
  describe 'post /api/v1/prices' do
    context 'list active all products and subscriptions plans' do
      before do
        get api_v1_pricing_path,
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns exam bodies and respective subscription plans and products json list' do
        body = JSON.parse(response.body)

        exam_bodies_hash         = body['exam_bodies']
        exam_body_sample         = exam_bodies_hash.sample
        product_sample           = exam_body_sample['products'].sample
        subscription_plan_sample = exam_body_sample['subscription_plans'].sample

        expect(exam_bodies_hash.map{ |e| e['id'] }).to include(exam_body_1.id)
        expect(exam_bodies_hash.map{ |e| e['url'] }).to include(exam_body_1.url)
        expect(exam_bodies_hash.map{ |e| e['name'] }).to include(exam_body_1.name)

        expect(exam_body_sample.keys).to include('id',
                                                 'name',
                                                 'url',
                                                 'subscription_plans',
                                                 'products')

        expect(product_sample.keys).to include('id',
                                               'name',
                                               'stripe_guid',
                                               'stripe_sku_guid',
                                               'active',
                                               'price',
                                               'product_type',
                                               'product_type_name',
                                               'product_type_url',
                                               'currency',
                                               'cbe',
                                               'course')

        expect(subscription_plan_sample.keys).to include('id',
                                                         'name',
                                                         'payment_frequency_in_months',
                                                         'price',
                                                         'guid',
                                                         'stripe_guid',
                                                         'paypal_guid',
                                                         'paypal_state',
                                                         'available_from',
                                                         'available_to',
                                                         'most_popular',
                                                         'currency',
                                                         'subscription_plan_category_id')


      end
    end

    context 'list active all products and subscriptions plans filtered by group' do
      before do
        get api_v1_pricing_path(group: group_1.name_url),
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns exam bodies and respective subscription plans and products json list' do
        body                     = JSON.parse(response.body)
        exam_body_hash           = body['exam_bodies']
        product_sample           = exam_body_hash['products'].sample
        subscription_plan_sample = exam_body_hash['subscription_plans'].sample

        expect(exam_body_hash['id']).to eq(group_1.id)
        expect(exam_body_hash['url']).to eq(group_1.name_url)
        expect(exam_body_hash['name']).to eq(group_1.name)

        expect(exam_body_hash.keys).to include('id',
                                                 'name',
                                                 'url',
                                                 'subscription_plans',
                                                 'products')

        expect(product_sample.keys).to include('id',
                                              'name',
                                              'stripe_guid',
                                              'stripe_sku_guid',
                                              'active',
                                              'price',
                                              'product_type',
                                              'product_type_name',
                                              'product_type_url',
                                              'currency',
                                              'cbe',
                                              'course')

        expect(subscription_plan_sample.keys).to include('id',
                                                         'name',
                                                         'payment_frequency_in_months',
                                                         'price',
                                                         'guid',
                                                         'stripe_guid',
                                                         'paypal_guid',
                                                         'paypal_state',
                                                         'available_from',
                                                         'available_to',
                                                         'most_popular',
                                                         'currency',
                                                         'subscription_plan_category_id')


      end
    end
  end
end
