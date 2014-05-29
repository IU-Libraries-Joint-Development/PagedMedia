class User < ActiveRecord::Base
# Connects this user object to Hydra behaviors. 
 include Hydra::User

  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4
# Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable, 
         :recoverable, :rememberable, :trackable, :validatable, :omniauth_providers => [:cas]

            # Method added by Blacklight; Blacklight uses #to_s on your
            # user class to get a user-displayable login/identifier for
            # the account.
            def to_s
              email
            end
  def self.find_for_iu_cas(auth)
    where(auth.slice(:provider, :uid)).first_or_create! do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = [auth.uid,'@indiana.edu'].join
      user.password = Devise.friendly_token[0,20]
    end
  end
end
