class User < ActiveRecord::Base
  attr_remote :name
  attr_remote :not_here
end