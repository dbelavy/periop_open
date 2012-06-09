# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require Rails.root.join('spec','helpers.rb')
require 'rubygems'           #so it can load gems


puts 'EMPTY THE MONGODB DATABASE'
Mongoid.master.collections.reject { |c| c.name =~ /^system/ }.each(&:drop)
puts 'SETTING UP DEFAULT USER LOGIN'
if ENV["RAILS_ENV"] == 'production'
  if ENV["ADMIN_PASSWORD"].nil?
    puts 'ADMIN_PASSWORD env variable should be not empty'
    raise
  end

  # for production to have secure password
  admin_email = ENV["ADMIN_EMAIL"].nil? ? 'admin@pre-op.net' : ENV["ADMIN_EMAIL"]
  user = User.create! :email => admin_email, :password => ENV["ADMIN_PASSWORD"], :password_confirmation => ENV["ADMIN_PASSWORD"], :confirmed_at => Time.now.utc
  user.assign_role 'admin'
else
  user = User.create! :email => dev_email('admin'), :password => '123456', :password_confirmation => '123456', :confirmed_at => Time.now.utc
  user.assign_role 'admin'
end
puts 'admin created: ' <<  user.email

