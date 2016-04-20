#Multitenancy with Rails 2016 review.


##The setup

- Create new app.

- Create migration that enable postgres uuid migration.

###UUID?

_**U**niversally **U**nique **ID**entifier_

Is a 16 bytes number (128 bits). So, posibilities of UUID are around 16^32 like 3,4 × 10^38. In its canonical form, a UUID is represented by 32 lowercase hexadecimal digits, displayed in five groups separated by hyphens, in the form 8-4-4-4-12 for a total of 36 characters (32 alphanumeric characters and four hyphens). For example:

```
550e8400-e29b-41d4-a716-446655440000
```

```
The Regexp:
/[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}/
```

```ruby
> SecureRandom.uuid
=> "03c0fc41-c144-4366-b5a3-8ac5aede4be5"
```

Take a look at this article: [Decentralise id generation](http://andrzejonsoftware.blogspot.mx/2013/12/decentralise-id-generation.html)

```shell
$ rails g migration enable_uuid_extension
```

```ruby
class EnableUuidExtension < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
  end
end
```

Creating a basic multitenancy application

Let's create our tenant model

```ruby
rails g model Tenant name subdomain status:integer
```

Please take a look at your migration, it will look like this:

```ruby
class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants, id: :uuid do |t|
      t.string :name
      t.string :subdomain
      t.integer :status

      t.timestamps null: false
    end
  end
end
```

###Our old friend [Devise](https://github.com/plataformatec/devise) (we love and hate him)

```ruby
# Gemfile
gem 'devise'
```

...and then:

```shell
$ bundle install
```

...and then:


```shell
$ rails generate devise:install
```

...and then:


```shell
$ rails generate devise User
```

...and then :S!

take a look at your migration and fix the id column with the code below

```ruby
1 class DeviseCreateUsers < ActiveRecord::Migration
2   def change
3     create_table :users, id: :uuid do |t|
4     ...
```

At this point theres no magic! but... we have to take a hard decision: how will our application works with users and tenants?

    A) Does our app support multiple tenants for one user?
    B) Or does our app just permit one user belongs to a single tenant?

if your answer is B you just need to add a reference column in the User model, something like this:

```ruby
class Tenant < ActiveRecord::Base
  has_many :users
  ...
```

The migration:

```shell
$ rails g migration add_tenant_to_users tenant:references
```

but...

#Oh lord, if things were so easy! :P

Remember, you have to fix your migration before running it.

```ruby
  def change
    add_reference :users, :tenant, foreign_key: true, type: :uuid
  end
```

But if your answer were A, you rock, you really want to live on the edge.

Ok, let's get back to the point, First we need to keep in mind some things about application behaviour.

1. As a mortal user, Am I able to signup in the app?
2. As an admin user, I have the ability to setup my users accounts.
3. When I want to suspend or remove user, Should I delete from DB or use soft delete instead?



###Some examples of multitenancy apps:

- Atlassian.
  something.atlassian.com/projects/324567
- Basecamp.
  basecamp.com/21345AD/projects/45674567
- Slack.
  myorganisation.slack.com



##The routes

###The big question: Subdomain or scope?

Please consider using prax (for linux) or pow (macos).

A great way to take advantage of raoute constraints

[The rails route mapper source code (+2k LOC)](https://github.com/rails/rails/blob/52ce6ece8c8f74064bb64e0a0b1ddd83092718e1/actionpack/lib/action_dispatch/routing/mapper.rb) TLDR;

```ruby
# lib/tenant_handler.rb

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
```

```ruby
# config/routes.rb
require 'tenant_handler'

Rails.application.routes.draw do

  # ...some code
  resources :pages

  devise_for :users

  constraints(TenantHandler::SubdomainBlank) do
    get '/', to: 'pages#index'
  end

  constraints(TenantHandler::SubdomainPresent) do
    root 'application#tenant'
  end
end
```

### Finding Tenant by subdomain

```ruby
  # application_controller.rb

  before_action :mount_tenant

  attr_accessor :current_tenant
  helper_method :current_tenant
  helper_method :subdomain?

  def mount_tenant
    @current_tenant = if subdomain? && @current_tenant.nil?
      Tenant.find_by(subdomain: request.subdomain)
    else
      nil
    end
  end

  def subdomain?
    request.subdomain.present? && !request.subdomain.include?('www')
  end
```