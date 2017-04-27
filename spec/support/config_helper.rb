module ConfigHelper
  def set_config
    Maxwell::Client.env = :sandbox
  end
end

RSpec.configure do |config|
  config.include ConfigHelper
end
