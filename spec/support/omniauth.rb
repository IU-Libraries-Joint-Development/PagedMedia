
def set_omniauth(opts = {})
  default = {:provider => :iu_cas,
             :uuid     => "1234",
             :iu_cas => {
                            :email => "mockuser@nowhere.edu",
                            :first_name => "mock",
                            :last_name => "user"
                          }
            }

  credentials = default.merge(opts)
  provider = credentials[:provider]
  user_hash = credentials[provider]

  OmniAuth.config.test_mode = true

  OmniAuth.config.mock_auth[provider] = {
    'uid' => credentials[:uuid],
    "extra" => {
    "user_hash" => {
      "email" => user_hash[:email],
      "first_name" => user_hash[:first_name],
      "last_name" => user_hash[:last_name],
      }
    }
  }
end

def set_invalid_omniauth(opts = {})

  credentials = { :provider => :iu_cas,
                  :invalid  => :invalid_crendentials
                 }.merge(opts)

  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[credentials[:provider]] = credentials[:invalid]

end

