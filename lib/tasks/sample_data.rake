require Rails.root.join('spec','helpers.rb')
require 'rubygems'           #so it can load gems


namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
  require 'factory_girl_rails' #so it can run in development
   Rake::Task['db:seed'].invoke
   Rake::Task['db:questions'].invoke
   10.times do |n|
     create_professional(Professional::ANAESTHETIST,'a'+n.to_s ,Faker::Name.name)
   end
   FactoryGirl.create( :patient , :name => 'Viktor Navorski')
   FactoryGirl.create(:patient,:name => 'Forrest Gump')

   10.times do
   FactoryGirl.create(:patient)
   end


   Patient.first.surgeon = Professional.surgeons.first
   10.times do |n|
     p = Patient.find(:all)[n]
     p.surgeon = Faker::Name.name + ' surgeon'
     p.anaesthetist= Professional.anaesthetists[Random.rand 3]
     p.assigned= Form.all.map{|f| f.name}
     p.save!
   end
  end

  task questions: :environment do

    Concept.delete_all
    Question.delete_all
    # populate questions
    Concept.create!(name: "Patient_Surname",display_name: "Surname")
    Concept.create!(name: "Patient_DOB",display_name: "DOB")
    Concept.create!(name: "Patient_Gender",display_name: "Gender")
    Concept.create!(name: "Parent_Guardian_Name",display_name: "Parent/Guardian_Name")

    Question.build_with_concept(display_name: "Surname", person_role: [Question::PROFESSIONAL],concept: "Patient_Surname")
    Question.build_with_concept(display_name: "Family name", person_role: [Question::PATIENT],concept: "Patient_Surname")

    Question.build_with_concept(display_name: "Date of birth",
                                person_role: [Question::PATIENT , Question::PROFESSIONAL],
                                concept: "Patient_DOB")

    Question.build_with_concept(display_name: "What is your gender", person_role: [Question::PATIENT],
                                concept: "Patient_Gender" )
    Question.build_with_concept(display_name: "Gender", person_role: [Question::PROFESSIONAL],
                                concept: "Patient_Gender" )
    Question.build_with_concept(display_name: "Parent/Guardian name" , conditions: "if DOB < 18 years ago",
                     person_role: [Question::PATIENT , Question::PROFESSIONAL],
                     concept: "Parent_Guardian_Name" )

    patient_form =  Form.create!(name: "Patient assessment", person_role: [Question::PATIENT])
    patient_form.questions.push Question.where(display_name: "Surname").first
    patient_form.questions.push Question.where(display_name: "Date of birth").first
    patient_form.questions.push Question.where(display_name: "Family name").first
    patient_form.questions.push Question.where(display_name: "What is your gender").first

    phone_form =  Form.create!(name: "Telephone Assessment", person_role: [Question::PROFESSIONAL])
    phone_form.questions.push Question.where(display_name: "Surname").first
    phone_form.questions.push Question.where(display_name: "Date of birth").first

    clinic_form =  Form.create!(name: "Clinic Assessment", person_role: [Question::PROFESSIONAL])
    clinic_form.questions.push Question.where(display_name: "Parent_Guardian_Name").first
    clinic_form.questions.push Question.where(display_name: "Date of birth").first

  end

end
