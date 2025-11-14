class ApplicationController < ActionController::Base
  include CacheableSettings
  include MultisitePerformance
  
  before_action :set_current_site
  before_action :set_time_zone
  before_action :validate_site_access

  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  protect_from_forgery with: :exception

  helper_method :navbar_items
  helper_method :current_site

  private

  def set_current_site
    @current_site = Current.site
    
    if @current_site.nil?
      # Fallback to default site if middleware didn't set it
      @current_site = Site.active.find_by(subdomain: 'www') || Site.active.first
      Current.site = @current_site if @current_site
    end
    
    # Store in instance variable for easy access
    @site = @current_site
  end

  def validate_site_access
    if @current_site.nil?
      render_error_page(404, "Site not found", "The requested site could not be found.")
      return false
    end
    
    # Ensure all queries are scoped to current site
    true
  end

  def set_time_zone
    if @current_site && @current_site.config(:time_zone).present?
      Time.zone = @current_site.config(:time_zone)
    else
      Time.zone = CacheableSettings.site_info[:time_zone] || "UTC"
    end
  end

  def current_site
    @current_site
  end

  def navbar_items
    @navbar_items ||= CacheableSettings.navbar_items
  end

  def refresh_settings
    CacheableSettings.refresh_site_info
  end

  def refresh_pages
    CacheableSettings.refresh_navbar_items
  end

  def render_error_page(status, title, message = nil)
    @error_title = title
    @error_message = message
    @error_status = status
    
    respond_to do |format|
      format.html { render 'errors/error', status: status }
      format.json { render json: { error: title, message: message }, status: status }
    end
  end

  # Scope all queries to current site for data isolation
  def scope_to_current_site(relation)
    relation.where(site_id: current_site.id)
  end

  # Ensure the record belongs to current site
  def verify_site_ownership(record)
    if record.respond_to?(:site_id) && record.site_id != current_site.id
      render_error_page(404, "Not Found", "The requested resource was not found.")
      return false
    end
    true
  end
end
