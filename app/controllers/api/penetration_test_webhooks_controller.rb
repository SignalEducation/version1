class Api::PenetrationTestWebhooksController < Api::BaseController

  before_action :ensure_staging_or_dev

  def test_starting
    # do nothing for now
    render nothing: true, status: 200
  end

  def test_complete
    tf_user = User.where(last_name: 'Tinfoil').first
    session_guid = UserActivityLog.where(user_id: tf_user.id).order(:created_at).last.session_guid
    PenetrationTestCleanupWorker.perform_async(tf_user.id, session_guid)
    render nothing: true, status: 200
  end

  protected

  def ensure_staging_or_dev
    unless Rails.env.staging? || Rails.env.development?
      Rails.logger.error 'ERROR: api/PenetrationTestWebhooksController activated outside of Staging'
      render nothing: true
      false
    end
  end

end
