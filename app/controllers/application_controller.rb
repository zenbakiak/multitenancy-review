class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :mount_tenant

  attr_accessor :current_tenant
  helper_method :current_tenant
  helper_method :subdomain?

  def mount_tenant
    @current_tenant = if subdomain? && @current_tenant.nil?
      Tenant.find_by(subdomain: request.subdomain)
    elsif params[:tenant_uuid].present?
      Tenant.find(params[:tenant_uuid])
    else
      nil
    end
  end

  def subdomain?
    request.subdomain.present? && !request.subdomain.include?('www')
  end


  def tenant
    render json: current_tenant and return
  end
end
