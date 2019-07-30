# frozen_string_literal: true

class StripeService
  # CUSTOMERS ==================================================================

  def create_customer!(user)
    customer = Stripe::Customer.create(email: user.email)
    user.update!(stripe_customer_id: customer.id)

    customer
  end

  def get_customer(stripe_customer_id)
    Stripe::Customer.retrieve(stripe_customer_id)
  end

  # PLANS ======================================================================

  def create_plan(subscription_plan)
    stripe_plan = Stripe::Plan.create(
      amount: (subscription_plan.price.to_f * 100).to_i,
      currency: subscription_plan.currency.iso_code.downcase,
      interval: 'month',
      interval_count: subscription_plan.payment_frequency_in_months,
      product: {
        name: "LearnSignal #{subscription_plan.name}",
        statement_descriptor: 'LearnSignal'
      },
      id: stripe_plan_id
    )

    update_subscription_plan(subscription_plan, stripe_plan)
  end

  def get_plan(stripe_plan_id)
    Stripe::Plan.retrieve(id: stripe_plan_id, expand: ['product'])
  end

  def update_plan(subscription_plan)
    stripe_plan              = get_plan(subscription_plan.stripe_guid)
    stripe_plan.product.name = "LearnSignal #{subscription_plan.name}"
    stripe_plan.product.save
  end

  def delete_plan(stripe_plan_id)
    plan = get_plan(stripe_plan_id)
    plan&.delete
  end

  # ORDERS =====================================================================

  def complete_purchase(order)
    stripe_order = create_order(order.product, order.user)
    order.assign_attributes(stripe_customer_id: stripe_order.customer,
                            stripe_guid: stripe_order.id,
                            live_mode: stripe_order.livemode,
                            stripe_status: stripe_order.status)
    if order.valid?
      pay_order = stripe_order.pay(source: order.stripe_token)
      order.stripe_status = pay_order.status
      order.stripe_order_payment_data = pay_order
      order
    else
      Rails.logger.error "DEBUG: Orders#create Unable to PAY an order - Order ID #{order.id} is not valid"
      raise Learnsignal::PaymentError, 'Sorry Something went wrong! Please contact us for assistance.'
    end
  rescue Stripe::CardError => e
    body = e.json_body
    err = body[:error]
    Rails.logger.error "DEBUG: Orders#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"
    raise Learnsignal::PaymentError, "Sorry! Your request was declined because - #{err[:message]}"
  rescue => e
    Rails.logger.error "DEBUG: Orders#create Failure for unknown reason - Error: #{e.inspect}"
    raise Learnsignal::PaymentError, 'Sorry Something went wrong! Please contact us for assistance.'
  end

  # SUBSCRIPTIONS ==============================================================

  def get_subscription(sub_id)
    Stripe::Subscription.retrieve(id: sub_id)
  end

  def change_plan(old_sub, new_plan_id)
    user = old_sub.user
    new_subscription_plan = SubscriptionPlan.find(new_plan_id)
    validate_plan_changable(old_sub, new_subscription_plan, user)

    if stripe_subscription = get_updated_subscription_from_stripe(old_sub, new_subscription_plan)
      ActiveRecord::Base.transaction do
        new_sub = Subscription.new(
            user_id: user.id,
            subscription_plan_id: new_plan_id,
            complimentary: false,
            livemode: (stripe_subscription[:plan][:livemode]),
            stripe_status: stripe_subscription[:status],
            changed_from: old_sub
        )
        # mass-assign-protected attributes

        ## This means it will have the same stripe_guid as the old Subscription ##
        new_sub.stripe_guid = stripe_subscription[:id]

        new_sub.next_renewal_date = Time.at(stripe_subscription[:current_period_end])
        new_sub.stripe_customer_id = old_sub.stripe_customer_id
        new_sub.stripe_customer_data = get_customer(old_sub.stripe_customer_id).to_hash
        new_sub.save(validate: false)
        new_sub.start

        user.student_access.update(subscription_id: new_sub.id, account_type: 'Subscription', content_access: true)

        # Only one subscription is active for a user at a time; when creating new subscriptions old ones must be set to active: false.
        old_sub.update(stripe_status: 'canceled')
        old_sub.cancel

        return new_sub
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("ERROR: Subscription#upgrade_plan - AR.Transaction failed.  Details: #{e.inspect}")
    raise Learnsignal::SubscriptionError, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe')
  rescue => e
    Rails.logger.error("ERROR: Subscription#upgrade_plan - failed to update Subscription at Stripe.  Details: #{e.inspect}")
    raise Learnsignal::SubscriptionError, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe')
  end

  def create_and_return_subscription(subscription, stripe_token, coupon)
    stripe_customer = Stripe::Customer.retrieve(subscription.user.stripe_customer_id)
    stripe_customer.source = stripe_token
    stripe_customer.save

    stripe_subscription = create_subscription(subscription, stripe_customer.id, coupon)
    client_secret       = stripe_subscription[:latest_invoice][:payment_intent][:client_secret]

    subscription.assign_attributes(
      complimentary: false,
      livemode: stripe_subscription[:plan][:livemode],
      stripe_status: stripe_subscription.status,
      stripe_guid: stripe_subscription.id,
      next_renewal_date: Time.at(stripe_subscription.current_period_end),
      stripe_customer_id: stripe_customer.id,
      coupon_id: coupon.try(:id),
      stripe_customer_data: stripe_customer.to_hash.deep_dup,
      payment_intent: stripe_subscription[:latest_invoice][:payment_intent][:status]
    )

    [subscription, client_secret]
  end

  def cancel_subscription(subscription)
    if subscription.stripe_customer_id && subscription.stripe_guid
      stripe_customer                          = Stripe::Customer.retrieve(subscription.stripe_customer_id)
      stripe_subscription                      = stripe_customer.subscriptions.retrieve(subscription.stripe_guid)
      stripe_subscription.cancel_at_period_end = true
      response                                 = stripe_subscription.save.to_hash

      if response[:status] == 'canceled'
        subscription.update(stripe_status: 'canceled-pending')
        subscription.cancel_pending
      else
        Rails.logger.error "ERROR: Subscription#cancel failed to cancel an 'active' sub. Self:#{subscription}. StripeResponse:#{response}."
        raise Learnsignal::SubscriptionError, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe')
      end
    else
      Rails.logger.error "ERROR: Subscription#cancel failed because it didn't have a stripe_customer_id OR a stripe_guid. Subscription:#{self}."
      raise Learnsignal::SubscriptionError, 'Subscription#cancel failed because it did not have a stripe_customer_id OR a stripe_guid.'
    end
  rescue Stripe::StripeError => e
    Rails.logger.error "DEBUG: Subscription#cancel_immediately got an error on Stripe #{e.inspect}"
    raise Learnsignal::SubscriptionError, 'Sorry! There was an error cancelling the subscription.'
  end

  def cancel_subscription_immediately(subscription)
    if subscription.stripe_customer_id && subscription.stripe_guid
      stripe_customer = Stripe::Customer.retrieve(subscription.stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.retrieve(subscription.stripe_guid)
      response = stripe_subscription.delete.to_hash
      if response[:status] == 'canceled'
        subscription.update(stripe_status: 'canceled')
        subscription.cancel
      else
        Rails.logger.error "ERROR: Subscription#cancel_immediately failed to cancel an 'active' sub. Self:#{subscription}. StripeResponse:#{response}."
        raise Learnsignal::SubscriptionError, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe')
      end
    else
      Rails.logger.error "ERROR: Subscription#cancel failed because it didn't have a stripe_customer_id OR a stripe_guid. Subscription:#{self}."
      raise Learnsignal::SubscriptionError, 'Subscription#cancel failed because it did not have a stripe_customer_id OR a stripe_guid.'
    end
  rescue Stripe::StripeError => e
    Rails.logger.error "DEBUG: Subscription#cancel_immediately got an error on Stripe #{e.inspect}"
    raise Learnsignal::SubscriptionError, 'Sorry! There was an error cancelling the subscription.'
  end

  # INVOICES ===================================================================

  def get_invoice(invoice_id)
    Stripe::Invoice.retrieve(id: invoice_id, expand: ['payment_intent'])
  end

  # PRIVATE ====================================================================

  private

  def create_order(product, user)
    Stripe::Order.create(
        currency: product.currency.iso_code,
        customer: user.stripe_customer_id,
        email: user.email,
        items: [{amount: (product.price.to_f * 100).to_i,
                 currency: product.currency.iso_code,
                 quantity: 1,
                 parent: product.stripe_sku_guid}]
    )
  rescue Stripe::CardError => e
    body = e.json_body
    err = body[:error]
    Rails.logger.error "DEBUG: Orders#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"
    raise Learnsignal::PaymentError, "Sorry! Your request was declined because - #{err[:message]}"
  rescue => e
    Rails.logger.error "DEBUG: Orders#create Failure for unknown reason - Error: #{e.inspect}"
    raise Learnsignal::PaymentError, 'Sorry Something went wrong! Please contact us for assistance.'
  end

  def get_updated_subscription_from_stripe(old_sub, new_subscription_plan)
    stripe_customer = get_customer(old_sub.stripe_customer_id)
    stripe_subscription = stripe_customer.subscriptions.retrieve(old_sub.stripe_guid)
    stripe_subscription.items.first.plan = new_subscription_plan.stripe_guid
    stripe_subscription.prorate = true
    stripe_subscription.trial_end = 'now'

    stripe_subscription.save
  rescue Stripe::CardError => e
    body = e.json_body
    err = body[:error]
    Rails.logger.error "DEBUG: Subscription#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"
    raise Learnsignal::SubscriptionError, "Sorry! Your request was declined because - #{err[:message]}"
  end

  def create_subscription(subscription, stripe_customer_id, coupon)
    Stripe::Subscription.create(
      customer: stripe_customer_id,
      items: [{ plan: subscription.subscription_plan.stripe_guid,
                quantity: 1 }],
      coupon: coupon.try(:code),
      trial_end: 'now',
      expand: ['latest_invoice.payment_intent']
    )
  rescue Stripe::CardError => e
    body = e.json_body
    err = e
    Rails.logger.error "DEBUG: Subscription#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"
    raise Learnsignal::SubscriptionError, "Sorry! Your request was declined because - #{err[:message]}"
  rescue => e
    Rails.logger.error "DEBUG: Subscription#create Failure for unknown reason - Error: #{e.inspect} --- #{e} ---- "
    raise Learnsignal::SubscriptionError, 'Sorry Something went wrong! Please contact us for assistance.'
  end

  def update_subscription_plan(subscription_plan, stripe_plan)
    subscription_plan.update(
        stripe_guid: stripe_plan.id,
        livemode: stripe_plan[:livemode]
    )
  end

  def stripe_plan_id
    Rails.env + '-' + ApplicationController.generate_random_code(20)
  end

  def validate_plan_changable(subscription, new_plan, user)
    if subscription.user.default_card.nil?
      raise Learnsignal::SubscriptionError,
            I18n.t('controllers.subscriptions.update.flash.invalid_card')
    elsif subscription.subscription_plan.currency_id != new_plan.currency_id
      raise Learnsignal::SubscriptionError,
            I18n.t('models.subscriptions.upgrade_plan.currencies_mismatch')
    elsif !new_plan.active?
      raise Learnsignal::SubscriptionError,
            I18n.t('models.subscriptions.upgrade_plan.new_plan_is_inactive')
    elsif %w[active past_due].exclude?(subscription.stripe_status)
      raise Learnsignal::SubscriptionError,
            I18n.t('models.subscriptions.upgrade_plan.this_subscription_cant_be_upgraded')
    elsif !user.standard_student_user?
      raise Learnsignal::SubscriptionError,
            I18n.t('models.subscriptions.upgrade_plan.you_are_not_permitted_to_upgrade')
    elsif user.subscription_payment_cards.all_default_cards.empty?
      raise Learnsignal::SubscriptionError,
            I18n.t('models.subscriptions.upgrade_plan.you_have_no_default_payment_card')
    end
  end
end
