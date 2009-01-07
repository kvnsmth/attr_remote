require File.dirname(__FILE__) + '/helper'

class TestAttrRemote < Test::Unit::TestCase
  context "general specs" do
    test "that attributes can be added multiple times" do
      assert_equal User.remote_attributes, [:name, :not_here]
    end
  end
  
  context "remote object access" do
    before do
      mock_user(@user = Factory(:user, :name => "Kevin"))
    end
    test "that an instance should have a method for the remote object" do
      assert @user.respond_to?(:remote_user)
    end
    test "that the remote object should be looked up based on the id" do
      assert_equal "Kevin", @user.remote_user.name
    end
  end
  
  context "reading" do
    test "that an instance should have a read method for the attribute" do
      user = Factory(:user)
      assert user.respond_to?(:name)
    end
    
    test "that the read method returns the correct value" do
      user = Factory(:user)
      assert_equal "Kevin", user.name
    end
    
    test "that after first read, an instance variable contains the value" do
      mock_user(user = Factory(:user))
      expected_name = user.name
      
      user = User.find(user.id)
      assert_nil user.instance_variable_get('@name')
      user.name
      assert_equal "Kevin", user.instance_variable_get('@name')
    end
    
    test "that an attribute will be empty if the remote side does not exist" do
      user = Factory.build(:user, :remote_user_id => 666, :name => nil)
      assert_equal '', user.name
    end
    
    test "that an attribute that is not readable returns an empty string" do
      user = Factory(:user)
      user = User.find(user.id)
      assert_equal '', user.not_here
    end
  end
  
  context "creation" do
    test "that an instance should have a writer method for the attribute" do
      user = Factory(:user)
      assert user.respond_to?(:name=)
    end
    test "that an instance reads correctly after writing" do
      user = Factory.build(:user, :name => "test")
      assert_equal "test", user.name
    end
    test "that the remote object id is set after creation" do
      user = Factory.build(:user, :remote_user_id => nil)
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/users.xml", {}, {
          :name => user.name
        }.to_xml(:root => "user"), 200, {
          'Location' => 'http://0.0.0.0:3000/users/1'
        }
      end
      assert user.save
      assert_not_nil user.remote_user_id
    end
    
    test "that remote errors halt save process" do
      bob = Bob.new(:title => "title")
      assert !bob.save
      assert_not_nil bob.errors.on(:email)
    end
    
    test "that failure of local validations halts remote creation and therefore remote errors do not show up" do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/bobs.xml", 
                  {}, 
                  returning(ActiveRecord::Errors.new(Bob.new)) { |errors|
                    errors.add(:email, "can't be blank")
                  }.to_xml, 422
      end
      bob = Bob.create(:title => nil)
      assert !bob.save
      assert_not_nil bob.errors.on(:title)
      assert_nil bob.errors.on(:email)
    end
    
    test "that after a successful creation an instance is marked as not having any remote changes" do
      user = Factory(:user, :remote_user_id => 2)
      assert !user.remote_attributes_changed?
    end
  end
  
  context "updates" do
    test "that a remote attribute change is propogated" do
      mock_user(user = Factory(:user))
      user.name = "boo"
      assert user.save
      mock_user(user)
      user = User.find(user.id)
      assert_equal "boo", user.name
    end
    
    test "that after a successful update an instance is marked as not having any remote changes" do
      user = Factory(:user)
      mock_user(user)
      user.name = "new name"
      assert user.save
      assert !user.remote_attributes_changed?
    end
    
    test "that save doesn't cause a remote hit if a remote attribute has not been changed" do
      user = Factory(:user, :remote_user_id => 2)
      # purposely not mocking the ARes call to "prove" 
      # that it isn't invoked on save
      assert user.save
    end
    
    test "that changing a local attribute does not trigger a remote save" do
      bob = Bob.new(:remote_bob_id => 3)
      bob.title = "test"
      assert bob.save
    end
  end
  
  context "deletes" do
  end
end