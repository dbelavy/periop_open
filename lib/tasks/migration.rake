require Rails.root.join('spec','helpers.rb')
require 'rubygems'           #so it can load gems

namespace :db do
  desc "Fill database with sample data"
  task migrate_patient_fields: :environment do
  Patient.all.each do |patient|

    patient.update_values
    puts 'patient updated'  + patient.to_s
  end

  end


end