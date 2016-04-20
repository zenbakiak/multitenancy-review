require 'tenant_handler'

Rails.application.routes.draw do
  get 'pages/index'

  devise_for :users

  constraints(TenantHandler::SubdomainBlank) do
    get '/', to: 'pages#index'
  end

  constraints(TenantHandler::SubdomainPresent) do
    root 'application#tenant'
  end


end
