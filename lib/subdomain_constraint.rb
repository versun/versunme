# Subdomain constraint for route optimization
class SubdomainConstraint
  def initialize(subdomain)
    @subdomain = subdomain
  end

  def matches?(request)
    case @subdomain
    when :main
      # Main site (no subdomain or www)
      request.subdomain.blank? || request.subdomain == 'www'
    when :any
      # Any subdomain (for catch-all routes)
      request.subdomain.present?
    else
      # Specific subdomain
      request.subdomain == @subdomain.to_s
    end
  end
end

# Helper class for subdomain routing
class SubdomainRouter
  def self.main_site(&block)
    constraints(SubdomainConstraint.new(:main), &block)
  end

  def self.any_site(&block)
    constraints(SubdomainConstraint.new(:any), &block)
  end

  def self.site(subdomain, &block)
    constraints(SubdomainConstraint.new(subdomain), &block)
  end
end