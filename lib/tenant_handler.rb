module TenantHandler
  class SubdomainPresent
    def self.matches?(request)
      request.subdomain.present? && !["www", "api"].include?(request.subdomain)
    end
  end

  class SubdomainBlank
    def self.matches?(request)
      request.subdomain.blank? || request.subdomain == 'www'
    end
  end
end
