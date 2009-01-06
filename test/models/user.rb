class User < ActiveRecord::Base
  attr_remote :name, :not_here
end