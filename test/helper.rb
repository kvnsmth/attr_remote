require 'test/unit'
require 'rubygems'

require File.join(File.dirname(__FILE__), '..', 'lib', 'attr_remote')
require 'active_resource/http_mock'

Dir['**/models/*.rb'].each do |model|
  require model
end

require 'redgreen'
require 'context'
require 'factory_girl'

ActiveRecord::Base.establish_connection({
  :adapter => 'sqlite3', 
  :dbfile => File.dirname(__FILE__) + '/db/test.db'
})

class Test::Unit::TestCase
  def mock_user(user)
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/users/#{user.remote_user_id}.xml", {}, {
        :id => user.remote_user_id,
        :name => user.name
      }.to_xml(:root => "user")
      mock.put "/users/#{user.remote_user_id}.xml", {}, '', 200, {}
    end
  end
  
  
  def teardown
    # cleanup all our test data
    User.delete_all
    Bob.delete_all
  end
end
