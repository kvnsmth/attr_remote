require File.dirname(__FILE__) + '/helper'

class TestAttrRemote < Test::Unit::TestCase
  context "remote object access" do
    before do
      @user = Factory(:user)
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
      user = Factory.build(:user, :name => nil, :remote_user_id => 1)
      assert_nil user.instance_variable_get('@name')
      user.name
      assert_equal "Kevin", user.instance_variable_get('@name')
    end
    
    test "that an attribute will be empty if the remote side does not exist" do
      user = Factory.build(:user, :remote_user_id => 666, :name => nil)
      assert_equal '', user.name
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
      user = Factory(:user, :name => "Kevin")
      assert_equal 1, user.remote_user_id
    end
    
    test "that remote errors halt save process" do
      bob = Bob.new(:title => "title")
      assert !bob.save
      assert_not_nil bob.errors.on(:email)
    end
    
    test "that failure of local validations halts remote creation and therefore remote errors do not show up" do
      bob = Bob.create(:title => nil)
      assert !bob.save
      assert_not_nil bob.errors.on(:title)
      assert_nil bob.errors.on(:email)
    end
  end
  
  context "updates" do
  end
  
  context "deletes" do
  end
end