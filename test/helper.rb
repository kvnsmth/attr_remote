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

ActiveResource::HttpMock.respond_to do |mock|
  # user is a successful creation
  mock.get "/users/1.xml", {}, {
    :name => "Kevin"
  }.to_xml(:root => "user")
  
  mock.post "/users.xml", {}, {
    :name => "Kevin"
  }.to_xml(:root => "user"), 200, {
    'Location' => 'http://0.0.0.0:3000/users/1'
  }
  
  mock.put "/users/1.xml", {}, '', 200, {}
  
  # bob is not so lucky
  mock.post "/bobs.xml", 
            {}, 
            returning(ActiveRecord::Errors.new(Bob.new)) { |errors|
              errors.add(:email, "can't be blank")
            }.to_xml, 422
end

class Test::Unit::TestCase
  def teardown
    # cleanup all our test data
    User.delete_all
    Bob.delete_all
  end
end
