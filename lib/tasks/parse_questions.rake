require Rails.root.join('spec', 'helpers.rb')
require 'rubygems' #so it can load gems


def parse_concepts(doc)
  Concept.delete_all
  doc.default_sheet = 'Concept heirarchy position'
  3.upto(360) do |line|
    concept = Concept.create!(
        name: doc.cell(line, 'A').downcase,
        display_name: doc.cell(line, 'B'),
        order_in_category: doc.cell(line, 'I'),
        mpog_code: doc.cell(line, 'J'),
        mpog_name: doc.cell(line, 'K'),
        snomed_code: doc.cell(line, 'L')
    )

    category_name = doc.cell(line, 'D').to_s
    arr = category_name.split(",")

    category = Category.where(level_1_name: arr[0],
                              level_2_name: arr[1]).first
    if category.nil?
      raise "Not found category " + category_name + " for line " + line.to_s
    end
    concept.category = category
    concept.save!
    puts 'created concept: ' + concept.to_s
  end
end

def parse_categories doc
  Category.delete_all
  #doc.default_sheet = doc.sheets['Data_Classification for Summary']
  doc.default_sheet = 'Data_Classification for Summary'

  2.upto(doc.last_row) do |line|
    level_1_name = doc.cell(line, 'B')
    level_1_order= doc.cell(line, 'C')
    level_2_name = doc.cell(line, 'D')
    level_2_order= doc.cell(line, 'E')
    summary_display= doc.cell(line, 'J')
    category = Category.create!(level_1_name: level_1_name,
                                level_1_order: level_1_order,
                                level_2_name: level_2_name,
                                level_2_order: level_2_order)
    puts 'created category : ' + category.to_s
  end
end

def create_forms
  Form.delete_all
  Form.create!(name: Form::NEW_PATIENT, person_role: [Question::PROFESSIONAL])
  Form.create!(name: Form::PATIENT_ASSESSMENT, person_role: [Question::PATIENT])
  Form.create!(name: Form::TELEPHONE_ASSESSMENT, person_role: [Question::PROFESSIONAL])
  Form.create!(name: Form::CLINIC_ASSESSMENT, person_role: [Question::PROFESSIONAL])
end

def column_for doc,name
  1.upto doc.last_column do |col|
    if doc.cell(1,col).to_s == name
      return col
    end
  end
end

def parse_questions doc
  Question.delete_all
  doc.default_sheet = 'Questions'
  new_patient_form = Form.where(name: Form::NEW_PATIENT).first
  patient_form = Form.where(name: Form::PATIENT_ASSESSMENT).first
  telephone_form = Form.where(name: Form::TELEPHONE_ASSESSMENT).first
  clinic_form = Form.where(name: Form::CLINIC_ASSESSMENT).first

  used_in_new_patient_col = column_for(doc,"New_Patient_Form")
  used_in_patient_assesment_col = column_for(doc,"Question used in patient assessment")
  used_in_professional_assesment_col = column_for(doc,"Question used in clinic or bedside assessment by professional")
  used_in_telephone_assesment_col = column_for(doc,"Question used in telephone assessment by professional")

  required_col = column_for(doc,"Required_field")

  validation_col = column_for(doc,"Validation_criteria")


  3.upto(doc.last_row) do |line|
    if doc.cell(line, "C").nil?
      next
    end

    condition = doc.cell(line, "F")
    if !condition.nil?

      if condition.downcase == "all"
        condition = ""
      else
        if /\S=\S/.match condition
          condition.gsub!("=", " = ")
        end
        if (/<\S/.match condition)
        condition.gsub!("<", "< ")
        end
        if (/\S</.match condition)
        condition.gsub!("<", " <")
        end
      end
      condition.gsub!(/\s[\s]*/, " ")
    end

    ask_details_criteria = doc.cell(line, "K").downcase if !doc.cell(line, "K").nil?
    ask_details_criteria ="all" if ask_details_criteria == "any answer"

    question = Question.create!(
                                question_id: doc.cell(line, "C"),
                                display_name: doc.cell(line, "E"),
                                condition: condition,
                                input_type: doc.cell(line, "G"),
                                text_length: doc.cell(line, "I"),
                                ask_details: doc.cell(line, "J"),
                                ask_details_criteria: ask_details_criteria,
                                option_list_name: doc.cell(line, "H"),
                                validation_criteria: doc.cell(line, validation_col)
                                )
    concept_name = doc.cell(line, "D").downcase
    question.concept = Concept.where(name: concept_name).first
    if question.concept.nil?
      raise "Not found concept " + concept_name
    end
    # used in patient assessment
    if doc.cell(line, used_in_patient_assesment_col)
      patient_form.questions.push question
    end
    if doc.cell(line, used_in_new_patient_col)
      new_patient_form.questions.push question
    end
    if doc.cell(line, used_in_telephone_assesment_col)
      #  add to form
      telephone_form.questions.push question
    end
    if doc.cell(line, used_in_professional_assesment_col)
      #  add to form
      clinic_form.questions.push question
    end
    #puts 'created question: ' + question.to_s
  end
end

def parse_option_lists doc
  OptionList.delete_all
  doc.default_sheet = 'Option_List'
  2.upto(doc.last_row) do |line|
    value = doc.cell(line, "D")
    if value.nil?
      value = " "
    end
    option_list = OptionList.create!(:name => doc.cell(line, "A"),
                                     :order_number => doc.cell(line, "B"),
                                     :label => doc.cell(line, "C"),
                                     :value => value)
    #puts 'created option List: ' + option_list.to_s
  end
end


  namespace :db do
    desc "Parse questions spreadsheet"
    task parse: :environment do
      require 'roo'

      #workbook = RubyXL::Parser.parse("./spreadsheet/Question_properties.xlsx")
      #workbook.worksheets[0] #returns first worksheet
      #row = workbook[0].sheet_data[0]  #returns first worksheet
      #puts row

      doc = Excelx.new("./spreadsheet/Question_properties.xlsx")
      create_forms
      parse_categories(doc)
      parse_concepts(doc)
      parse_questions doc
      parse_option_lists doc
    end
  end