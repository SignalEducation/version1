class SubscriptionService
  attr_reader :subscription

  def create_subscription(params)
    @subscription = Subscription.new(subscription_params)
    stripe_token = params[:subscription][:stripe_token]
    coupon_code = params[:hidden_coupon_code] if params[:hidden_coupon_code].present?

    unless stripe_token && @subscription && @subscription.subscription_plan
      flash[:error] = 'Sorry! The data entered is not valid. Please contact us for assistance.'
      redirect_to request.referrer and return
    end

    user = @subscription.user
    subscription_plan_stripe_guid = @subscription.subscription_plan.stripe_guid
    stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
    @coupon = Coupon.get_and_verify(coupon_code, @subscription.subscription_plan_id) if coupon_code

    if coupon_code && !@coupon
      flash[:error] = 'Sorry! That is not a valid coupon code.'
      redirect_to request.referrer and return
    end

    begin
      stripe_subscription = Stripe::Subscription.create(
          customer: user.stripe_customer_id,
          plan: subscription_plan_stripe_guid,
          source: stripe_token,
          coupon: @coupon.try(:code),
          trial_end: 'now'
      )

      stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id) #Reload the stripe_customer to get new Subscription details

      @subscription.assign_attributes(
          complimentary: false,
          active: true,
          livemode: stripe_subscription[:plan][:livemode],
          current_status: stripe_subscription.status,
          stripe_guid: stripe_subscription.id,
          next_renewal_date: Time.at(stripe_subscription.current_period_end),
          stripe_customer_id: stripe_customer.id,
          coupon_id: @coupon.try(:id),
          stripe_customer_data: stripe_customer.to_hash.deep_dup
      )
      if @subscription.valid? && @subscription.save
        user.referred_signup.update_attributes(payed_at: Proc.new{Time.now}.call, subscription_id: @subscription.id) if user.referred_user
        redirect_to personal_upgrade_complete_url
      else
        Rails.logger.error "DEBUG: Subscription Failed to save for unknown reason - #{@subscription.inspect}"
        flash[:error] = 'Your request was declined. Please contact us for assistance!'
        redirect_to new_subscription_url
      end


    rescue Stripe::CardError => e
      body = e.json_body
      err  = body[:error]

      Rails.logger.error "DEBUG: Subscription#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"

      flash[:error] = "Sorry! Your request was declined because - #{err[:message]}"
      redirect_to request.referrer

    rescue => e
      Rails.logger.error "DEBUG: Subscription#create Failure for unknown reason - Error: #{e.inspect}"
      flash[:error] = 'Sorry Something went wrong! Please contact us for assistance.'
      redirect_to request.referrer
    end
  end
end