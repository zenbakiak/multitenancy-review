require 'tenant_handler'

Rails.application.routes.draw do
  resources :pages

  devise_for :users

  constraints(TenantHandler::SubdomainBlank) do
    get '/', to: 'pages#index'
  end

  constraints(TenantHandler::SubdomainPresent) do
    root 'application#tenant'
  end


  scope ':tenant_uuid', as: :tenant_uuid do
    get '/', to: 'application#tenant'
  end

end
