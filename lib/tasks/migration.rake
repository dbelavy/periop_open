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

  task anesthetist: :environment do
    fix_anaesthetist
  end

  def fix_anaesthetist
    Patient.all.each do |p|
      p.keys.each do |k|
          if k.include? "anaesthetist" ;
      tmp = doc[k]
      puts 'found key old : ' + k.to_s + ' store value : ' + tmp.to_s
      new_key = k.gsub("anaesthetist","anesthetist")
      puts " new key " + new_key
      arr << {:new_key => new_key,:value => tmp ,  :key => k}
    end
  end
  arr.each do |hash|
    doc[hash[:key]]=nil
    doc[hash[:new_key]]= hash[:value]
  end
  doc.update
    end
    end

end