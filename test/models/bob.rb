class Bob < ActiveRecord::Base
  validates_presence_of :title
  
  attr_remote :email, :foo
  
  def validate_remote_bob_on_create
    errors.add(:foo, "has already been taken") if foo == "taken"
  end
end