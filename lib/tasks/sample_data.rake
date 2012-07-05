require Rails.root.join('spec','helpers.rb')
require 'rubygems'           #so it can load gems


namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
  require 'factory_girl_rails' #so it can run in development
   Rake::Task['db:seed'].invoke
  #if ENV["RAILS_ENV"] == 'production'
    create_professional(Professional::ANAESTHETIST,"david@belavy.com","David Belavy")
  #end
   10.times do |n|
     create_professional_dev(Professional::ANAESTHETIST,'a'+n.to_s ,Faker::Name.name)
   end
  FactoryGirl.create( :patient , :name => 'Viktor Navorski',ssn: "1234567")
  FactoryGirl.create(:patient,:name => 'Forrest Gump',ssn: "555555")

  Rake::Task['db:questions'].invoke
  end

  def setup_patients
      FactoryGirl.create( :patient , :name => 'Viktor Navorski',ssn: "1234567")
      FactoryGirl.create(:patient,:name => 'Forrest Gump',ssn: "555")
      #10.times do
      #  FactoryGirl.create(:patient)
      #end
      Patient.first.surgeon = Professional.surgeons.first
      11.times do |n|
        p = Patient.find(:all)[n]
        p.surgeon = Faker::Name.name + ' surgeon'
        p.anaesthetist= Professional.anaesthetists[Random.rand 3]
        p.save!
      end
  end

  task questions: :environment do

    Concept.delete_all
    OptionList.delete_all
    Question.delete_all
    Form.delete_all
    # populate questions
    Concept.create!(name: "Patient_Surname",display_name: "Surname")
    Concept.create!(name: "Patient_DOB",display_name: "DOB")
    Concept.create!(name: "Patient_Gender",display_name: "Gender")
    Concept.create!(name: "Parent_Guardian_Name",display_name: "Parent/Guardian_Name")
    Concept.create!(name: "Pregnacy",display_name: "Pregnacy")
    Concept.create!(name: "Allergies",display_name: "Allergies")
    Concept.create!(name: "Allergy_cause_reaction",display_name: "Allergy_cause_reaction")

    # option list
    OptionList.create!(:name => "Y_N_U_Clinician",:order_number => 1, :label => "Unknown",:value => "Unknown")
    OptionList.create!(:name => "Y_N_U_Clinician",:order_number => 2, :label => "Yes",:value => "Yes")
    OptionList.create!(:name => "Y_N_U_Clinician",:order_number => 3, :label => "No",:value => "No")

    OptionList.create!(:name => "Y_N_U_Patient",:order_number => 1, :label => "Don't know",:value => "Unknown")
    OptionList.create!(:name => "Y_N_U_Patient",:order_number => 2, :label => "Yes",:value => "Yes")
    OptionList.create!(:name => "Y_N_U_Patient",:order_number => 3, :label => "No",:value => "No")

    OptionList.create!(:name => "Gender_clinician",:order_number => 1, :label => "Unknown",:value => "Unknown")
    OptionList.create!(:name => "Gender_clinician",:order_number => 2, :label => "Female",:value => "Female")
    OptionList.create!(:name => "Gender_clinician",:order_number => 3, :label => "Male",:value => "Male")
    OptionList.create!(:name => "Gender_clinician",:order_number => 4, :label => "Other",:value => "Other")

    OptionList.create!(:name => "Gender_patient",:order_number => 1, :label => "Female",:value => "Female")
    OptionList.create!(:name => "Gender_patient",:order_number => 2, :label => "Male",:value => "Male")

    Question.build_with_concept(display_name: "Surname", person_role: [Question::PROFESSIONAL],concept: "Patient_Surname",
                                input_type: "text")
    Question.build_with_concept(display_name: "Family name", person_role: [Question::PATIENT],concept: "Patient_Surname",
                                input_type: "text")

    Question.build_with_concept(display_name: "Allergy", person_role: [Question::PROFESSIONAL],concept: "Allergies")
    Question.build_with_concept(display_name:
                                "Do you have any allergies including medicines, latex rubber, tapes or food?",
                                person_role: [Question::PATIENT],concept: "Allergies")


    Question.build_with_concept(display_name: "Allergy cause and reaction", condition: "Allergies = Yes", person_role: [Question::PROFESSIONAL],concept: "Allergy_cause_reaction",
                                input_type: "text")
    Question.build_with_concept(display_name: "What are you allergic to?", condition: "Allergies = Yes", person_role: [Question::PATIENT],concept: "Allergy_cause_reaction",
                                input_type: "text")

    Question.build_with_concept(short_name: "Pregnacy" ,display_name: "Current pregnancy", person_role: [Question::PROFESSIONAL],
                                concept: "Pregnacy", condition: "gender = female")
    Question.build_with_concept(display_name: "Are you pregnant?", person_role: [Question::PATIENT],
                                concept: "Pregnacy", condition: "gender = female")

    Question.build_with_concept(display_name: "Date of birth",input_type: 'date',
                                person_role: [Question::PATIENT , Question::PROFESSIONAL],
                                concept: "Patient_DOB")

    Question.build_with_concept(display_name: "What is your gender", person_role: [Question::PATIENT],
                                concept: "Patient_Gender",option_list_name: "Gender_patient" ,input_type: 'OneOption')
    Question.build_with_concept(display_name: "Gender", person_role: [Question::PROFESSIONAL],
                                concept: "Patient_Gender",
                                option_list_name: "Gender_clinician",input_type: 'OneOption')
    Question.build_with_concept(display_name: "Parent/Guardian name" , condition: "age < 18",
                     person_role: [Question::PATIENT , Question::PROFESSIONAL],input_type: "text",
                     concept: "Parent_Guardian_Name" )

    patient_form =  Form.create!(name: Form::PATIENT_ASSESSMENT, person_role: [Question::PATIENT])

    patient_form.questions.push Question.where(display_name: "Date of birth").first
    patient_form.questions.push Question.where(display_name: "Family name").first
    patient_form.questions.push Question.where(display_name: "What is your gender").first
    patient_form.questions.push Question.where(display_name: "Are you pregnant?").first
    patient_form.questions.push Question.where(display_name: "Do you have any allergies including medicines, latex rubber, tapes or food?").first
    patient_form.questions.push Question.where(display_name: "What are you allergic to?").first

    phone_form =  Form.create!(name: "Telephone Assessment", person_role: [Question::PROFESSIONAL])

    phone_form.questions.push Question.where(display_name: "Surname").first
    phone_form.questions.push Question.where(display_name: "Date of birth").first
    phone_form.questions.push Question.where(display_name: "Allergy").first
    phone_form.questions.push Question.where(display_name: "What are you allergic to?").first

    clinic_form =  Form.create!(name: "Clinic Assessment", person_role: [Question::PROFESSIONAL])

    clinic_form.questions.push Question.where(display_name: "Parent/Guardian name").first
    clinic_form.questions.push Question.where(display_name: "Date of birth").first
    clinic_form.questions.push Question.where(display_name: "Gender").first
    clinic_form.questions.push Question.where(display_name: "Current pregnancy").first
    clinic_form.questions.push Question.where(display_name: "Allergy").first
    clinic_form.questions.push Question.where(display_name: "Allergy cause and reaction").first

    Assessment.delete_all
    #10.times do |n|
    #  p = Patient.find(:all)[n]
    #  #assign assesments
    #  p.assigned= Form.all.map{|f| f.name}
    #  p.save!
    #end
  end
end
