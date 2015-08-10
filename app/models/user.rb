class User < ActiveRecord::Base
  has_many :goals, dependent: :destroy

  has_secure_password
end
