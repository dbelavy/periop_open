require Rails.root.join('spec', 'helpers.rb')
require 'rubygems' #so it can load gems

namespace :db do
  desc "Fill database with sample data"
  task migrate_patient_fields: :environment do
    Patient.all.each do |patient|

      patient.update_values
      puts 'patient updated' + patient.to_s
    end
  end

  task anesthetist: :environment do
    fix_anaesthetist
  end

  def fix_anaesthetist
    Patient.all.each do |p|
      arr = []
      p.attributes.each do |attr|
        key = attr[0]
        if key.include? "anaesthetist";
          #puts 'attribute ' + attr.to_s
          tmp = attr[1]
          #puts 'found key old : ' + key.to_s + ' store value : ' + tmp.to_s
          new_key = key.gsub("anaesthetist", "anesthetist")
          if (p[new_key].nil?)
            arr << {:new_key => new_key, :value => tmp, :key => key}
          end
        end
      end
      arr.each do |hash|
        p[hash[:key]]=nil
        puts "setting "  + hash[:key] + "=>  nil "
        p[hash[:new_key]]= hash[:value]
        puts "setting "  + hash[:new_key] + "=>  " + hash[:value]
      end
      puts "new object" + p.to_s
      p.update
    end
  end

end