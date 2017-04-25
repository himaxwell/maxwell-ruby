module ConfigHelper
  def set_config
    Maxwell::Client.base_url = 'https://example.com/api'
  end
end

RSpec.configure do |config|
  config.include ConfigHelper
end
