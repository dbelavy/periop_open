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

  task fix_old_dates: :environment do
    start_date = Date.new(1900)
    date_q = Question.where(:input_type => "Date")
    Assessment.where({"answers.date_value" => { "$lt" => start_date.to_time }}).each do |a|
      date_q.each do |q|
        answer = a.answer q
        if !answer.nil?
          if answer.date_value.nil?
            puts ' answers date_value is nil :' + answer.to_s + ' ' + answer._id.to_s + q.display_name
          else
            if answer.date_value < start_date
              puts answer.value_to_s
              answer.date_value = answer.date_value + 100.years
              answer.save!
            end
          end
        end
      end
    end

    Patient.all.each do |p|
      if (!p.dob.nil? ) &&(p.dob < start_date)
        p.update_values
        puts ' patient :'  + p.dob.to_s + ().to_s + ' ' + p.firstname + p.surname
      end
    end
  end

  task migrate: :environment do
    #Rake::Task['db:synchronise_anesthetists'].invoke
    update_assessments
    update_unassigned_assessments
    delete_unused_concepts_and_questions

    Rake::Task['db:check_and_fix_data'].invoke
    Rake::Task['db:migrate_patient_fields'].invoke
    Rake::Task['db:lookup_field_value'].invoke
  end

  def update_unassigned_assessments
    puts ' update_unassigned_assessments '
    Assessment.unassigned.each do |a|
      #this will run callbacks again so anesthetist will be assigned if available
      puts a.inspect
      a.save
    end
  end


  def delete_unused_concepts_and_questions
    deleted_concept_names = Concept.all.map{|c| c.name}
    doc = Excelx.new("./spreadsheet/Question_properties.xlsx")
    doc.default_sheet = 'Concept heirarchy position'
    3.upto(doc.last_row) do |line|
        if doc.cell(line, 'A').blank?
          next
        end
        name = doc.cell(line, 'A').downcase
        deleted_concept_names.delete(name)
    end
    deleted_concept_names.each do |name|
      concept = Concept.where(name: name).first
      Question.where(concept_id: concept._id).each do |q|
        puts "Question removed " + q.display_name
        q.remove
      end
      puts "Concept removed " + concept.name
      concept.remove
    end
  end

  def update_assessments
    Assessment.all.each do |a|
      if a.name.nil?
        puts 'assesment name is nil ' + a._id.to_s
        if !a.form_id.nil?
          a.name= Form.find(a.form_id).name
          a.save!
        else
          puts 'assesment :' + a._id.to_s + 'has no name or form assigned '
        end
      end
      #a.upsert
    end
  end

  task anesthetist: :environment do
    fix_anaesthetist
  end

  task synchronise_anesthetists: :environment do
    Patient.all.each do |patient|
      puts 'Patient: ' + patient.firstname + ' ' + patient.surname + '  ' + patient._id.to_s
      if patient.get_answer_from_patient_form("anesthetist")
        puts 'patient form values: ' + patient.get_answer_from_patient_form("anesthetist").id_value
      else
        if patient.anesthetist_id
          puts 'setting patient form values from self field :' + patient.anesthetist_id.to_s
          patient.set_answer_value_by_concept "anesthetist",patient.anesthetist_id
        else
          puts '!!! neither self or patient_form anaesthetist is set, resolve manually'
        end
      end
    end
  end


  task lookup_field_value: :environment do
    q_ids = Question.where(input_type: "Lookup_User_Anesthetist").map{|q| q._id}
    puts q_ids.to_s
    Assessment.all.each do |a|
      answers = a.answers.in(question_id: q_ids)
      if (!answers.nil?)
        puts 'answers  ' + answers.to_s + ' '+ answers.size.to_s
        answers.each do |ans|
          if ans.value_to_s.blank?
            puts 'skipping empty answer'
            next
          end
          puts " lookup answer found : " + ans._id.to_s + " : "  + ans.value_to_s.to_s
          professional = Professional.where(name: ans[:value]).first
          if !professional.nil?
            puts ' found : '  +Professional.where(name: ans[:value]).size.to_s + ' professionals'
            ans[:value] = professional._id
            ans.save!
          end
          if (ans[:id_value].nil? || ans[:id_value].blank?)
          puts 'setting id_value ' + ans[:value].to_s + "answer " + ans.inspect
          ans[:id_value] = ans[:value]
          ans[:value] = nil
          ans.save!
          end
        end
      end
    end
  end

  def fix_anaesthetist
    # change all *anAEsthetist* attributes to *anEsthetist*
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

    Professional.all.each do |p|
      if p.speciality == "Anaesthetist"
        p.speciality = "Anesthetist"
        p.save
      end
    end


  end


  def check_sections
    Form.all.each do |form|
      puts 'checking form' + form.name
      open_tag = ""
      form.questions.sorted.each do |q|
        if q.input_type == 'Start_section'
          if open_tag.blank?
          open_tag = q.display_name
            puts 'start_section' + open_tag
          else
            puts '! trying to open new section ' + q.display_name  + ' previously open section ' + open_tag + ' not been closed'
          end
        end

        if q.input_type == 'End_section'
          if open_tag.downcase == q.display_name.downcase
            open_tag = ""
            puts 'end_section' + open_tag
          else
            puts '!!! trying to close section ' + q.display_name +  ' but previously open section ' + open_tag + ' not been closed'
          end
        end

      end
      if !open_tag.blank?
        puts 'previously open section ' + open_tag + ' not been closed'
      end
    end
  end

  task check_sections: :environment do
    check_sections
  end

  task safe_for_test: :environment do
    i = 0
    User.all.each do |u|
      if u.admin?
        email = dev_email ("ad" + i.to_s )
      else
        email = dev_email ("p" + i.to_s )
      end
      i += 1
      puts 'setting u ' + u.to_s + ' email to ' + email
      params = {}
      params[:password] ="123456"
      params[:password_confirmation ] = "123456"
      params[:email] = email
      u.update_with_password params
      u.save!
    end

    end

end