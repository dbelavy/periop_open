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

def create_professional(options = {})
  puts options.inspect
  options[:password] = options[:password] || default_password
  role = 'professional'
  user = User.create!(:email => options[:email], :password => options[:password],
                      :password_confirmation => options[:password], :confirmed_at => Time.now.utc,
  )
  user.assign_role role
  user.send(role).update_attributes(:name => options[:name],:speciality => options[:speciality])
  return user
end


def default_password
  "secret"
end

def check_conditon cond_str
  concepts_names = Concept.all.map{|c| c.name }
  #puts concepts_names.to_s
  if cond_str.blank? ||  cond_str.downcase == "all"
    return true
  end
  arr = cond_str.split(" ")
  if arr.size == 3
    result = [arr[0]]
  else
    result = parseOperation cond_str,  "and"
    if (!result)
      result = parseOperation cond_str,  "or"
      puts 'OR condition ' + cond_str

    end
  end

  result.each do |condition|

    if  concepts_names.index( condition.downcase).nil?
      puts 'Condition : ' + cond_str + ' contains wrong concept name ' + condition
      return false
    end
  end
end

def parseOperation(condStr, operation)
  if condStr.include?(" " + operation + " ") != -1
    cond_arr = []
    arr = condStr.split(" " + operation + " ")
    for atomic_str in arr
      cond_arr << atomic_str.split(" ")[0]
    end
    cond_arr
  end
end
