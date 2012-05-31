def dev_email param
  'alexander.khitev+' + param + '@gmail.com'
end

def create_user( role, email,name)
  user = User.create!(:email => dev_email(email), :password => '123456', :password_confirmation => '123456', :confirmed_at => Time.now.utc)
  user.assign_role role
  user.send(role).update_attribute(:name, name)
  return user
end

def create_patient(name)
  #create(:patient,:name => name)
end

