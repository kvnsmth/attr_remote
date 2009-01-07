Factory.sequence :remote_user_id do |n|
  n
end

Factory.define :user do |u|
  u.name "Kevin"
  u.remote_user_id { Factory.next(:remote_user_id) }
end