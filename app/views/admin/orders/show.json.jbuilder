# frozen_string_literal: true

json.extract! @order, :id, :product_id, :subject_course_id, :user_id, :stripe_guid, :stripe_customer_id, :live_mode, :stripe_status, :coupon_code, :created_at, :updated_at
