class ErrorsController < ApplicationController
  skip_before_action :validate_site_access
  
  def error_404
    render_error_page(404, "Page Not Found", "The page you requested could not be found.")
  end
  
  def error_500
    render_error_page(500, "Internal Server Error", "Something went wrong. Please try again later.")
  end
  
  def site_not_found
    render_error_page(404, "Site Not Found", "The requested site could not be found.")
  end
end