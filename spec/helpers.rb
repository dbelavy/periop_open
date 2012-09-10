def dev_email param
  'alexander.khitev+' + param + '@gmail.com'
end

def create_professional_dev(speciality, email, name)
  role = 'professional'
  user = User.create!(:email => dev_email(email), :password => default_password,
                      :password_confirmation => default_password, :confirmed_at => Time.now.utc,
                      )
  user.assign_role role
  user.send(role).update_attributes(:name => name,:speciality => speciality)
  return user
end

def create_professional(speciality, email, name)
  role = 'professional'
  user = User.create!(:email => email, :password => default_password,
                      :password_confirmation => default_password, :confirmed_at => Time.now.utc,
  )
  user.assign_role role
  user.send(role).update_attributes(:name => name,:speciality => speciality)
  return user
end


def create_patient(name)
  #create(:patient,:name => name)
end

def default_password
  "123456"
end