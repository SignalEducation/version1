class Subdomain
  def self.matches?(request)
    case request.subdomain
      when 'www', '', nil, 'learnsignal', 'staging', 'acca', 'cfa', 'forum', 'jobs'
        false
      else
        true
    end
  end
end
