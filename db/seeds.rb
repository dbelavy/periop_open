# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require Rails.root.join('spec','helpers.rb')
require 'rubygems'           #so it can load gems
require 'factory_girl_rails' #so it can run in development



puts 'EMPTY THE MONGODB DATABASE'
Mongoid.master.collections.reject { |c| c.name =~ /^system/ }.each(&:drop)
puts 'SETTING UP DEFAULT USER LOGIN'

if ENV["ADMIN_PASSWORD"].nil?
  puts 'ADMIN_PASSWORD env variable should be not empty'
  raise
end
if ENV["RAILS_ENV"] == 'production'
  # for production to have secure password
  user = User.create! :email => 'admin@production.com', :password => ENV["ADMIN_PASSWORD"], :password_confirmation => ENV["ADMIN_PASSWORD"], :confirmed_at => Time.now.utc


else
  user = User.create! :email => dev_email('admin'), :password => '123456', :password_confirmation => '123456', :confirmed_at => Time.now.utc
  user.assign_role 'admin'
end
puts 'admin created: ' <<  user.email
