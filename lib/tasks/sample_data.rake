require Rails.root.join('spec','helpers.rb')
require 'rubygems'           #so it can load gems
require 'factory_girl_rails' #so it can run in development

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
   Rake::Task['db:seed'].invoke
   create_user('doctor','doctor','Dr House')
   create_user('patient','patient','Mr Navorski')
   create_user('patient','patient1','Forrest Gump')

  end
end
