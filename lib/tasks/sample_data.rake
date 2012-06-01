require Rails.root.join('spec','helpers.rb')
require 'rubygems'           #so it can load gems
require 'factory_girl_rails' #so it can run in development

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
   Rake::Task['db:seed'].invoke
   10.times do |n|
     create_professional(Professional::SURGEON,'s' + n.to_s  ,Faker::Name.name)
   end
   10.times do |n|
     create_professional(Professional::ANAESTHETIST,'a'+n.to_s ,Faker::Name.name)
   end
   FactoryGirl.create(:patient,:name => 'Viktor Navorski')
   FactoryGirl.create(:patient,:name => 'Forrest Gump')

   10.times do
   FactoryGirl.create(:patient)
   end


   Patient.first.surgeon = Professional.surgeons.first
   10.times do |n|
     p = Patient.find(:all)[n]
     p.surgeon = Professional.surgeons[Random.rand 3]
     p.anaesthetist= Professional.anaesthetists[Random.rand 3]
     p.save!
   end



  end
end
