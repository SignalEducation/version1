class Subdomain
  def self.matches?(request)
    case request.subdomain
      when 'www', '', nil, 'learnsignal'
        false
      else
        true
    end
  end
end
