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