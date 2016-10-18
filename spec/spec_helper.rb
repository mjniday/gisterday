require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
   config.before do
      allow($stdout).to receive(:puts)
   end
end