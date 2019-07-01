module UserAccountsHelper
  def account_cancellation_message(subscription)
    if subscription.next_renewal_date
      t('views.users.show.confirm_cancellation_modal') +
        "on #{humanize_stripe_date_full(@subscription.next_renewal_date)} and you will then lose access to all the benefits shown above."
    else
      t('views.users.show.confirm_cancellation_modal')
    end
  end
end
