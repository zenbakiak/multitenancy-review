class Member < ActiveRecord::Base
  belongs_to :tenant
  belongs_to :user

  enum status: [:pending, :active, :suspended]
end
