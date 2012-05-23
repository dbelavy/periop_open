# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
def dev_email param
  'alexander.khitev+' + param + '@gmail.com'
end

puts 'EMPTY THE MONGODB DATABASE'
Mongoid.master.collections.reject { |c| c.name =~ /^system/ }.each(&:drop)
puts 'SETTING UP DEFAULT USER LOGIN'

if ENV["RAILS_ENV"] == 'production'
  if ENV["ADMIN_PASSWORD"].nil?
    puts 'ADMIN_PASSWORD env variable should be not empty'
    raise
  end
  # for production to have secure password
  user = User.create! :name => 'Admin', :email => 'admin@production.com', :password => ENV["AMDIN_PASSWORD"], :password_confirmation => ENV["AMDIN_PASSWORD"], :confirmed_at => Time.now.utc
else
  user = User.create! :name => 'Admin', :email => dev_email('admin'), :password => '123456', :password_confirmation => '123456', :confirmed_at => Time.now.utc
  user.assign_role 'admin'
end

puts 'admin created: ' << user.name + user.email

#TODO move to separate task for development\test only
user = User.create! :name => 'First User', :email => dev_email('doctor'), :password => '123456', :password_confirmation => '123456', :confirmed_at => Time.now.utc
user.assign_role 'doctor'

puts 'New doctor created: ' << user.name + user.email
user = User.create! :name => 'First User', :email => dev_email('patient'), :password => '123456', :password_confirmation => '123456', :confirmed_at => Time.now.utc
user.assign_role 'patient'
puts 'New patient created: ' << user.name + user.email
