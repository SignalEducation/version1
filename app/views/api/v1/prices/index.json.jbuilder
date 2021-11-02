# frozen_string_literal: true

if @group
  json.exam_bodies do
    json.id @group.id
    json.name @group.name
    json.url @group.name_url

    json.subscription_plans do
      if @subscription_plans.present?
        json.array! @subscription_plans do |plan|
          json.partial! 'plan', locals: { plan: plan }
        end
      else
        json.nil!
      end
    end

    json.products do
      if @subscription_plans.present?
        json.array! @products do |product|
          json.partial! 'product', locals: { product: product }
        end
      else
        json.nil!
      end
    end
  end
else
  json.exam_bodies do
    json.array! @exam_bodies do |exam_body|
      json.id exam_body.id
      json.name exam_body.name
      json.url exam_body.url

      json.subscription_plans do
        if @subscription_plans.present?
          json.array! @subscription_plans do |plan|
            json.partial! 'plan', locals: { plan: plan }
          end
        else
          json.nil!
        end
      end

      json.products do
        if @products.present?
          json.array! @products.includes(:mock_exam, :cbe) do |product|
            json.partial! 'product', locals: { product: product }
          end
        else
          json.nil!
        end
      end
    end
  end
end
