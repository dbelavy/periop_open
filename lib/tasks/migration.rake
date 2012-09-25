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

  task lookup_field_value: :environment do
    q_ids = Question.where(input_type: "Lookup_User_Anesthetist").map{|q| q._id}
    puts q_ids.to_s
    Assessment.all.each do |a|
      answers = a.answers.in(question_id: q_ids)
      if (!answers.nil?)
        puts 'answers  ' + answers.to_s + ' '+ answers.size.to_s
        answers.each do |ans|
          puts " lookup answer found : " + ans._id.to_s + " : "  + ans.value_to_s.to_s
          professional = Professional.where(name: ans[:value]).first
          if !professional.nil?
            puts ' found : '  +Professional.where(name: ans[:value]).size.to_s + ' professionals'
            ans[:value] = professional._id
            ans.save!
          end
          if (ans[:id_value].nil? || ans[:id_value].blank?)
          puts 'setting id_value ' + ans[:value].to_s
          ans[:id_value] = ans[:value]
          ans[:value] = nil
          ans.save!
          end
        end
      end
    end
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
        puts "setting "  + hash[:key].to_s + "=>  nil "
        p[hash[:new_key]]= hash[:value]
        puts "setting "  + hash[:new_key].to_s + "=>  " + hash[:value].to_s
      end
      puts "new object" + p.to_s
      p.update
    end
  end

end