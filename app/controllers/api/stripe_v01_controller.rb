class Api::StripeV01Controller < Api::BaseController

  protect_from_forgery except: :create

  def create
    if params[:id]
      # StripeApiProcessorWorker.perform_async(params[:id], Stripe.api_version)
      Rails.logger.debug "DEBUG: Api/StripeV01#Create: safe-data ID:#{params[:id]} queued OK."
      render text: nil, status: 200
    elsif params[:type] == 'ping'
      Rails.logger.debug 'DEBUG: Api/StripeV01#Create: ping received.'
      render text: nil, status: 204
    else
      Rails.logger.error "ERROR: Api/StripeV01#Create: NO data: #{params}"
      render text: nil, status: 404
    end
  rescue => e
    Rails.logger.error "ERROR: Api/StripeV01#Create: Error: #{e.inspect}"
    render text: nil, status: 204 # no content
  end


  protected

  #### Possible events

  ## Charges to our customers
  #  charge.succeeded
  #  charge.failed
  #  charge.refunded
  #  charge.captured
  #  charge.updated
  #  charge.dispute.created
  #  charge.dispute.updated
  #  charge.dispute.closed
  #  charge.dispute.funds_withdrawn
  #  charge.dispute.funds_reinstated

  ## Customers
  #  customer.created
  #  customer.updated
  #  customer.deleted

  ## Customer Cards (?)
  #  customer.card.created
  #  customer.card.updated
  #  customer.card.deleted

  ## Customer Subscriptions
  #  customer.subscription.created
  #  customer.subscription.updated
  #  customer.subscription.deleted
  #  customer.subscription.trial_will_end

  ## Invoices
  #  invoice.created
  #  invoice.updated
  #  invoice.payment_succeeded
  #  invoice.payment_failed
  #  invoiceitem.created
  #  invoiceitem.updated
  #  invoiceitem.deleted

  ## Plans
  #  plan.created
  #  plan.updated
  #  plan.deleted

  # ping

  #### Invoices

  def invoice_payment_succeeded(payload)
    sample = {
            id: 'test_evt_1',
            created: 1326853478,
            livemode: false,
            type: 'invoice.payment_succeeded',
            object: 'event',
            data: {
                    object: {
                            id: 'in_00000000000000',
                            date: 1394018368,
                            period_start: 1394018368,
                            period_end: 1394018368,
                            lines: {
                                    object: 'list',
                                    count: 3,
                                    url: '/v1/invoices/in_00000000000000/lines',
                                    data: [
                                            {
                                                    id: 'ii_00000000000000',
                                                    object: 'line_item',
                                                    type: 'invoiceitem',
                                                    livemode: false,
                                                    amount: 19000,
                                                    currency: 'usd',
                                                    proration: true,
                                                    period: {
                                                            start: 1393765661,
                                                            end: 1393765661
                                                    },
                                                    quantity: nil,
                                                    plan: nil,
                                                    description: 'Remaining time on Platinum after 02 Mar 2014',
                                                    metadata: {}
                                            },
                                            {
                                                    id: 'ii_00000000000001',
                                                    object: 'line_item',
                                                    type: 'invoiceitem',
                                                    livemode: false,
                                                    amount: -9000,
                                                    currency: 'usd',
                                                    proration: true,
                                                    period: {
                                                            start: 1393765661,
                                                            end: 1393765661
                                                    },
                                                    quantity: nil,
                                                    plan: nil,
                                                    description: 'Unused time on Gold after 05 Mar 2014',
                                                    metadata: {}
                                            },
                                            {
                                                    id: 'su_00000000000000',
                                                    object: 'line_item',
                                                    type: 'subscription',
                                                    livemode: false,
                                                    amount: 20000,
                                                    currency: 'usd',
                                                    proration: false,
                                                    period: {
                                                            start: 1383759053,
                                                            end: 1386351053
                                                    },
                                                    quantity: 1,
                                                    plan: {
                                                            id: 'platinum',
                                                            interval: 'month',
                                                            name: 'Platinum',
                                                            created: 1300000000,
                                                            amount: 20000,
                                                            currency: 'usd',
                                                            object: 'plan',
                                                            livemode: false,
                                                            interval_count: 1,
                                                            trial_period_days: nil,
                                                            metadata: {}
                                                    },
                                                    description: nil,
                                                    metadata: nil
                                            }
                                    ]
                            },
                            subtotal: 30000,
                            total: 30000,
                            customer: 'cus_00000000000000',
                            object: 'invoice',
                            attempted: true,
                            closed: true,
                            paid: true,
                            livemode: false,
                            attempt_count: 1,
                            amount_due: 0,
                            currency: 'usd',
                            starting_balance: 0,
                            ending_balance: 0,
                            next_payment_attempt: nil,
                            charge: 'ch_00000000000000',
                            discount: nil,
                            application_fee: nil,
                            subscription: 'su_00000000000000',
                            metadata: {},
                            description: nil
                    }
            }
    }
    ####
  end

  def invoice_payment_failed(payload)
    sample = {
            id: 'test_evt_1',
            created: 1326853478,
            livemode: false,
            type: 'invoice.payment_failed',
            object: 'event',
            data: {
                    object: {
                            id: 'in_00000000000000',
                            date: 1380674206,
                            period_start: 1378082075,
                            period_end: 1380674075,
                            lines: {
                                    object: 'list',
                                    count: 3,
                                    url: '/v1/invoices/in_00000000000000/lines',
                                    data: [
                                            {
                                                    id: 'ii_00000000000000',
                                                    object: 'line_item',
                                                    type: 'invoiceitem',
                                                    livemode: false,
                                                    amount: 19000,
                                                    currency: 'usd',
                                                    proration: true,
                                                    period: {
                                                            start: 1393765661,
                                                            end: 1393765661
                                                    },
                                                    quantity: nil,
                                                    plan: nil,
                                                    description: 'Remaining time on Platinum after 02 Mar 2014',
                                                    metadata: {}
                                            },
                                            {
                                                    id: 'ii_00000000000001',
                                                    object: 'line_item',
                                                    type: 'invoiceitem',
                                                    livemode: false,
                                                    amount: -9000,
                                                    currency: 'usd',
                                                    proration: true,
                                                    period: {
                                                            start: 1393765661,
                                                            end: 1393765661
                                                    },
                                                    quantity: nil,
                                                    plan: nil,
                                                    description: 'Unused time on Gold after 05 Mar 2014',
                                                    metadata: {}
                                            },
                                            {
                                                    id: 'su_00000000000000',
                                                    object: 'line_item',
                                                    type: 'subscription',
                                                    livemode: false,
                                                    amount: 20000,
                                                    currency: 'usd',
                                                    proration: false,
                                                    period: {
                                                            start: 1383759053,
                                                            end: 1386351053
                                                    },
                                                    quantity: 1,
                                                    plan: {
                                                            id: 'platinum',
                                                            interval: 'month',
                                                            name: 'Platinum',
                                                            created: 1300000000,
                                                            amount: 20000,
                                                            currency: 'usd',
                                                            object: 'plan',
                                                            livemode: false,
                                                            interval_count: 1,
                                                            trial_period_days: nil,
                                                            metadata: {}
                                                    },
                                                    description: nil,
                                                    metadata: nil
                                            }
                                    ]
                            },
                            subtotal: 30000,
                            total: 30000,
                            customer: 'cus_00000000000000',
                            object: 'invoice',
                            attempted: true,
                            closed: false,
                            paid: false,
                            livemode: false,
                            attempt_count: 1,
                            amount_due: 30000,
                            currency: 'usd',
                            starting_balance: 0,
                            ending_balance: 0,
                            next_payment_attempt: 1380760475,
                            charge: 'ch_00000000000000',
                            discount: nil,
                            application_fee: nil,
                            subscription: 'su_00000000000000',
                            metadata: {},
                            description: nil
                    }
            }
    }
    ####
  end

  #### Charges

  def charge_succeeded(payload)
    sample = {
            id: 'test_evt_1',
            created: 1326853478,
            livemode: false,
            type: 'charge.succeeded',
            object: 'event',
            data: {
                    object: {
                            id: 'ch_00000000000000',
                            object: 'charge',
                            created: 1380933505,
                            livemode: false,
                            paid: true,
                            amount: 1000,
                            currency: 'usd',
                            refunded: false,
                            card: {
                                    id: 'cc_00000000000000',
                                    object: 'card',
                                    last4: '4242',
                                    type: 'Visa',
                                    brand: 'Visa',
                                    exp_month: 12,
                                    exp_year: 2013,
                                    fingerprint: 'wXWJT135mEK107G8',
                                    customer: 'cus_00000000000000',
                                    country: 'US',
                                    name: 'Actual Nothing',
                                    address_line1: nil,
                                    address_line2: nil,
                                    address_city: nil,
                                    address_state: nil,
                                    address_zip: nil,
                                    address_country: nil,
                                    cvc_check: nil,
                                    address_line1_check: nil,
                                    address_zip_check: nil
                            },
                            captured: true,
                            refunds: {},
                            balance_transaction: 'txn_00000000000000',
                            failure_message: nil,
                            failure_code: nil,
                            amount_refunded: 0,
                            customer: 'cus_00000000000000',
                            invoice: 'in_00000000000000',
                            description: nil,
                            dispute: nil,
                            metadata: {}
                    }
            }
    }
    ####
  end

  def charge_failed(payload)
    sample = {
            id: 'test_evt_1',
            created: 1326853478,
            livemode: false,
            type: 'charge.failed',
            object: 'event',
            data: {
                    object: {
                            id: 'ch_00000000000000',
                            object: 'charge',
                            created: 1380933505,
                            livemode: false,
                            paid: false,
                            amount: 1000,
                            currency: 'usd',
                            refunded: false,
                            card: {
                                    id: 'cc_00000000000000',
                                    object: 'card',
                                    last4: '4242',
                                    type: 'Visa',
                                    brand: 'Visa',
                                    funding: 'credit',
                                    exp_month: 12,
                                    exp_year: 2013,
                                    fingerprint: 'wXWJT135mEK107G8',
                                    customer: 'cus_00000000000000',
                                    country: 'US',
                                    name: 'Actual Nothing',
                                    address_line1: nil,
                                    address_line2: nil,
                                    address_city: nil,
                                    address_state: nil,
                                    address_zip: nil,
                                    address_country: nil,
                                    cvc_check: nil,
                                    address_line1_check: nil,
                                    address_zip_check: nil
                            },
                            captured: true,
                            refunds: {},
                            balance_transaction: 'txn_00000000000000',
                            failure_message: nil,
                            failure_code: nil,
                            amount_refunded: 0,
                            customer: 'cus_00000000000000',
                            invoice: 'in_00000000000000',
                            description: nil,
                            dispute: nil,
                            metadata: {}
                    }
            }
    }
    ####
  end

  #### Customers

  def customer_created(payload)
    sample = {
            id: 'test_evt_1',
            created: 1326853478,
            livemode: false,
            type: 'customer.created',
            object: 'event',
            data: {
                    object: {
                            id: 'cus_00000000000000',
                            object: 'customer',
                            created: 1375148334,
                            livemode: false,
                            description: nil,
                            email: 'bond@mailinator.com',
                            delinquent: true,
                            metadata: {},
                            subscription: nil,
                            discount: nil,
                            account_balance: 0,
                            cards: {
                                    object: 'list',
                                    count: 1,
                                    url: '/v1/customers/cus_2I2AhGQOPmEFeu/cards',
                                    data: [
                                            {
                                                    id: 'cc_2I2akIhmladin5',
                                                    object: 'card',
                                                    last4: '0341',
                                                    type: 'Visa',
                                                    brand: 'Visa',
                                                    funding: 'credit',
                                                    exp_month: 12,
                                                    exp_year: 2013,
                                                    fingerprint: 'fWvZEzdbEIFF8QrK',
                                                    customer: 'cus_2I2AhGQOPmEFeu',
                                                    country: 'US',
                                                    name: 'Johnny Goodman',
                                                    address_line1: nil,
                                                    address_line2: nil,
                                                    address_city: nil,
                                                    address_state: nil,
                                                    address_zip: nil,
                                                    address_country: nil,
                                                    cvc_check: 'pass',
                                                    address_line1_check: nil,
                                                    address_zip_check: nil
                                            }
                                    ]
                            },
                            default_card: 'cc_2I2akIhmladin5'
                    }
            }
    }
  end

  #### Customer subscriptions

  def customer_subscription_trial_will_end(payload)
    sample = {
            id: 'test_evt_1',
            created: 1326853478,
            livemode: false,
            type: 'customer.subscription.trial_will_end',
            object: 'event',
            data: {
                    object: {
                            id: 'su_00000000000000',
                            plan: {
                                    id: 'fkx0AFo_00000000000000',
                                    interval: 'month',
                                    name: "Member's Club",
                                    amount: 100,
                                    currency: 'usd',
                                    object: 'plan',
                                    livemode: false,
                                    interval_count: 1,
                                    trial_period_days: nil
                            },
                            object: 'subscription',
                            start: 1381080623,
                            status: 'trialing',
                            customer: 'cus_00000000000000',
                            cancel_at_period_end: false,
                            current_period_start: 1381080623,
                            current_period_end: 1383759023,
                            ended_at: nil,
                            trial_start: 1381021530,
                            trial_end: 1381280730,
                            canceled_at: nil,
                            quantity: 1,
                            application_fee_percent: nil
                    }
            }
    }
    ####
  end

  def customer_subscription_updated(payload)
    sample = {
            id: 'test_evt_1',
            created: 1326853478,
            livemode: false,
            type: 'customer.subscription.updated',
            object: 'event',
            data: {
                    object: {
                            id: 'su_00000000000000',
                            plan: {
                                    id: 'fkx0AFo_00000000000000',
                                    interval: 'month',
                                    name: "Member's Club",
                                    amount: 100,
                                    currency: 'usd',
                                    object: 'plan',
                                    livemode: false,
                                    interval_count: 1,
                                    trial_period_days: nil
                            },
                            object: 'subscription',
                            start: 1381080561,
                            status: 'active',
                            customer: 'cus_00000000000000',
                            cancel_at_period_end: false,
                            current_period_start: 1381080561,
                            current_period_end: 1383758961,
                            ended_at: nil,
                            trial_start: nil,
                            trial_end: nil,
                            canceled_at: nil,
                            quantity: 1,
                            application_fee_percent: nil
                    },
                    previous_attributes: {
                            plan: {
                                    id: 'OLD_PLAN_ID',
                                    interval: 'month',
                                    name: 'Old plan',
                                    amount: 100,
                                    currency: 'usd',
                                    object: 'plan',
                                    livemode: false,
                                    interval_count: 1,
                                    trial_period_days: nil
                            }
                    }
            }
    }
    ####
  end

end
