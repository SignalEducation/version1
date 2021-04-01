# See https://github.com/mperham/sidekiq/wiki/Monitoring

class AdminConstraint
  def matches?(request)
    return false unless request.session.key?(:user_credentials)

    user = User.find_by(persistence_token: request.session.fetch(:user_credentials))
    user && (user.developer_access? || user.user_management_access? || user.system_requirements_access?)
  end
end
