require Rails.root.join('spec', 'helpers.rb')
require 'rubygems' #so it can load gems


def parse_concepts(doc)
  Concept.delete_all
  doc.default_sheet = doc.sheets[2]
  2.upto(doc.last_row) do |line|
    concept = Concept.create!(
        name: doc.cell(line, 'A'),
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
    concept.category = category
    concept.save!
    puts 'created concept: ' + concept.to_s
  end
end

def parse_categories doc
  Category.delete_all
  doc.default_sheet = doc.sheets[1]
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

  Form.create!(name: Form::PATIENT_ASSESSMENT, person_role: [Question::PATIENT])
  Form.create!(name: Form::TELEPHONE_ASSESSMENT, person_role: [Question::PROFESSIONAL])
  Form.create!(name: Form::CLINIC_ASSESSMENT, person_role: [Question::PROFESSIONAL])
end


def parse_questions doc
  Question.delete_all
  doc.default_sheet = doc.sheets[3]
  patient_form =Form.where(name: Form::PATIENT_ASSESSMENT).first
  telephone_form =Form.where(name: Form::TELEPHONE_ASSESSMENT).first
  clinic_form =Form.where(name: Form::CLINIC_ASSESSMENT).first
  2.upto(doc.last_row) do |line|
    person_role = []
    question = Question.create!(display_name: doc.cell(line,"E"),
                                condition: doc.cell(line,"F"),
                                input_type: doc.cell(line,"G"),
                                option_list_name: doc.cell(line,"H")
                                )
    # used in patient assessment
    if doc.cell(line,"L")
      #person_role << Question::PATIENT
      patient_form.questions.push question
    end
    if doc.cell(line,"M")
      #person_role << Question::PROFESSIONAL
      #  add to form
      patient_form.questions.push question
    end
    if doc.cell(line,"N")
      #person_role << Question::PROFESSIONAL if person_role.find(Question::PROFESSIONAL).nil?
      #  add to form
      clinic_form.questions.push question
    end
    puts 'created question: ' + question.to_s
  end
end

def parse_option_lists doc
  OptionList.delete_all
  doc.default_sheet = doc.sheets[4]
  2.upto(doc.last_row) do |line|
    option_list = OptionList.create!(:name => doc.cell(line,"A"),
                       :order_number => doc.cell(line,"B"),
                       :label => doc.cell(line,"C"),
                       :value => doc.cell(line,"D"))
    puts 'created option List: ' + option_list.to_s
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

    #oo = Openoffice.new("./spreadsheet/Question_properties.xlsx")
    doc = Excelx.new("./spreadsheet/Question_properties.xlsx")

    create_forms
    parse_categories(doc)
    parse_concepts(doc)
    parse_questions doc
    parse_option_lists doc
  end
end
