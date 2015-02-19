class Api::StripeV01Controller < ApplicationController

  ACCEPTED_TYPES = %w(invoice.create invoice.payment_succeeded invoice.payment_failed charge.succeeded customer.subscription.trial_will_end customer.subscription.updated)

  protect_from_forgery except: :create

  def create
    validation_ok, message = validate_message(params[:message])
    unless validation_ok
      Rails.logger.error "ERROR: Api/StripeV01#Create received invalid data: #{message}"
    end
    render text: nil, status: 200
  end

  protected

  def call_stripe_back(payload)
    validation_ok = false
    Stripe::Event.retrieve(params[:id])
    new_payload = payload
    return validation_ok, new_payload
  end

  def permitted_params
    params.require(:data).permit(
            :id, # "evt_15Xt6G2eZvKYlo2CtOlC0trl"
            :created, # 1424347692
            :livemode, # false
            :type, # "customer.subscription.updated"
            data: {
                object: { :id }, # "sub_4QoCEkz0qPydHI",
                plan: {
                    :interval, # "month"
                    :name, # "Starter"
                    :created, #1405771481
                    :amount, # 0
                    :currency, # "usd"
                    :id, # "fqo-da
                    :object, # "plan"
                    :livemode, # false
                    :interval_count, # 1
                    :trial_period_days, # null
                    metadata: {},
                    :statement_descriptor, # null
                },
                :object, # "subscription"
                :start, # 1405771482
            "status": "active",
            "customer": "cus_4QoCxFTxsXnZw8",
            "cancel_at_period_end": false,
    "current_period_start": 1424347482,
            "current_period_end": 1426766682,
            "ended_at": null,
    "trial_start": null,
    "trial_end": null,
    "canceled_at": null,
    "quantity": 1,
            "application_fee_percent": null,
    "discount": null,
    "tax_percent": null,
    "metadata": {
    }
    },
            "previous_attributes": {
            "current_period_start": 1421669082,
            "current_period_end": 1424347482
    }
    },
            "object": "event",
            "pending_webhooks": 0,
            "request": null,
    "api_version": "2015-02-18"
    }


    )
  end

  def validate_message(payload)
    validation_status, new_payload = call_stripe_back(payload)
    return validation_status, new_payload
  end

  #### Invoices

  def invoice_create(payload)
    ####
  end

  def invoice_payment_succeeded(payload)
    ####
  end

  def invoice_payment_failed(payload)
    ####
  end

  #### Charges

  def charge_succeeded(payload)
    ####
  end

  def charge_failed(payload)
    ####
  end

  #### Customer subscriptions

  def customer_subscription_trial_will_end(payload)
    ####
  end

  def customer_subscription_updated(payload)
    ####
  end

end
