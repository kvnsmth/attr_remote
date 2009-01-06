class RemoteBob < ActiveResource::Base
  self.site = "http://0.0.0.0:3000/"
  self.element_name = "bob"
end