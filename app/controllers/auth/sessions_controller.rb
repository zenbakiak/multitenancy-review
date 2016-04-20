class Auth::SessionsController < Devise::SessionsController
  # def new
  #   # super
  # end

  def create
    # Super will allow you to pass the authentication and let you execute your code.
    super do |user|
      sign_out(:user) unless user.active?

      tenant = user.members && user.members.first.tenant
      if tenant
        redirect_to root_url(subdomain: tenant.slug) and return
      else
        sign_out(:user)
      end
    end
  end


end
