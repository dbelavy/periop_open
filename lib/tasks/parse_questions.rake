require Rails.root.join('spec', 'helpers.rb')
require 'rubygems' #so it can load gems


def parse_concepts(doc)
  all_names = Concept.all.map{|c| c.name}
  puts "parse_concepts"
  doc.default_sheet = 'Concept heirarchy position'
  3.upto(doc.last_row) do |line|
    if doc.cell(line, 'A').blank?
      next
    end


    name = doc.cell(line, 'A').downcase
    if name.include? ' '
      raise "concept_name contains space " + name + " for line " + line.to_s
    end
    if(!Concept.exists?(:conditions => {name: name}))
       puts 'creating new concept : ' + name
    end
    all_names.delete(name)
    concept = Concept.find_or_create_by(name: name)
    concept.update_attributes!(
        display_name: doc.cell(line, 'B'),
        order_in_category: doc.cell(line, 'I'),
        mpog_code: doc.cell(line, 'K'),
        mpog_name: doc.cell(line, 'L'),
        snomed_code: doc.cell(line, 'M'),
        conflict_resolution:doc.cell(line, 'J')
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
    #puts 'created concept: ' + concept.to_s
  end

  if (all_names.size > 0)
    puts '!!! concepts with following names now not exist :' + all_names.to_s
    check_concept_by_names all_names
  end

end

def check_concept_by_names names
  names.each do |name|
    concept = Concept.where(name: name).first
    Question.where(concept_id: concept._id).each do |q|
      puts "Question related to unexisting concept : " + q.display_name
    end
  end
end

def parse_categories doc
  puts "parse_categories "
  doc.default_sheet = 'Data_Classification for Summary'

  2.upto(doc.last_row) do |line|
    level_1_name = doc.cell(line, 'B')
    level_1_order= doc.cell(line, 'C')
    level_2_name = doc.cell(line, 'D')
    level_2_order= doc.cell(line, 'E')
    summary_display= doc.cell(line, 'J')
    category = Category.find_or_create_by(level_1_name: level_1_name,
                                          level_2_name: level_2_name)

    category.update_attributes(level_1_order: level_1_order,
                               level_2_order: level_2_order,
                               summary_display: summary_display)

    #puts 'created category : ' + category.to_s
  end
end


def delete_data
  puts 'delete_data'
  Form.delete_all
  Category.delete_all
  Concept.delete_all
  Question.delete_all
end

def create_forms
  puts 'create_forms'
  Form.find_or_create_by(name: Form::NEW_PATIENT).update_attributes(person_role: [Question::PROFESSIONAL])
  Form.find_or_create_by(name: Form::PATIENT_ASSESSMENT).update_attributes(person_role: [Question::PATIENT])
  Form.find_or_create_by(name: Form::TELEPHONE_ASSESSMENT).update_attributes(person_role: [Question::PROFESSIONAL])
  Form.find_or_create_by(name: Form::CLINIC_ASSESSMENT).update_attributes(person_role: [Question::PROFESSIONAL])
  Form.find_or_create_by(name: Form::NEW_OPERATION).update_attributes(person_role: [Question::PROFESSIONAL])
  Form.find_or_create_by(name: Form::QUICK_NOTE_ASSESSMENT).update_attributes(person_role: [Question::PROFESSIONAL])
end

def column_for doc,name
  1.upto doc.last_column do |col|
    if doc.cell(1,col).to_s == name
      return col
    end
  end
end

def parse_questions doc
  puts 'parse_questions'
  doc.default_sheet = 'Questions'
  new_patient_form = Form.where(name: Form::NEW_PATIENT).first
  new_patient_form.clear_questions

  patient_form = Form.where(name: Form::PATIENT_ASSESSMENT).first
  patient_form.clear_questions

  telephone_form = Form.where(name: Form::TELEPHONE_ASSESSMENT).first
  telephone_form.clear_questions

  clinic_form = Form.where(name: Form::CLINIC_ASSESSMENT).first
  clinic_form.clear_questions

  note_form = Form.where(name: Form::QUICK_NOTE_ASSESSMENT).first
  note_form.clear_questions

  operation_form = Form.where(name: Form::NEW_OPERATION).first
  operation_form.clear_questions

  used_in_new_patient_col = column_for(doc,"New_Patient_Form")
  used_in_patient_assessment_col = column_for(doc,"Question used in patient assessment")
  used_in_professional_assessment_col = column_for(doc,"Professional_assessment")
  used_in_telephone_assessment_col = column_for(doc,"Question used in telephone assessment by professional")
  used_in_new_operation_assessment_col = column_for(doc,"New_Operation_Form")
  used_in_quick_note_assessment_col = column_for(doc,"Quick_note")

  required_col = column_for(doc,"Required_field")

  validation_col = column_for(doc,"Validation_criteria")

  all_question_ids = Question.all.map{|q| q.question_id}

  2.upto(doc.last_row) do |line|
    if doc.cell(line, "D").nil?
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

    check_conditon condition

    ask_details_criteria = doc.cell(line, "K").downcase if !doc.cell(line, "K").nil?
    ask_details_criteria ="all" if ask_details_criteria == "any answer"

    question_id = doc.cell(line, "C")
    all_question_ids.delete(question_id)

    if(!Question.exists?(:conditions => {question_id: question_id}))
      puts 'creating new questions : ' + question_id.to_s
    end

    question = Question.find_or_create_by(question_id: question_id)
    #puts "overall pos: " + doc.cell(line, "A").to_s
    question.update_attributes!(question_id: question_id,
                                display_name: doc.cell(line, "E"),
                                condition: condition,
                                input_type: doc.cell(line, "G"),
                                text_length: doc.cell(line, "I"),
                                ask_details: doc.cell(line, "J"),
                                ask_details_criteria: ask_details_criteria,
                                option_list_name: doc.cell(line, "H"),
                                validation_criteria: doc.cell(line, validation_col),
                                sort_order: doc.cell(line, "A").to_i
                                )
    concept_name = doc.cell(line, "D").downcase
    question.concept = Concept.where(name: concept_name).first
    question.save!
    if question.concept.nil?
      raise "Not found concept " + concept_name
      puts "Not found concept " + concept_name
    end
    # used in patient assessment
    if doc.cell(line, used_in_patient_assessment_col)
      patient_form.questions.push question
    end
    if doc.cell(line, used_in_new_patient_col)
      new_patient_form.questions.push question
    end
    if doc.cell(line, used_in_telephone_assessment_col)
      #  add to form
      telephone_form.questions.push question
    end
    if doc.cell(line, used_in_professional_assessment_col)
      #  add to form
      clinic_form.questions.push question
    end
    if doc.cell(line, used_in_new_operation_assessment_col)
      #  add to form
      operation_form.questions.push question
    end

    if doc.cell(line, used_in_quick_note_assessment_col)
      #  add to form
      note_form.questions.push question
    end
    #puts 'created question: ' + question.to_s
  end

  if (all_question_ids.size > 0)
    puts '!!! question with following ids now not exist : ' + all_question_ids.to_s
  end

end

def setup_question_order
  puts "setup_question_order"
  Question.all.each do |question|
    concept = question.concept
    if concept.nil?
      puts 'question ' + question.display_name + ' has no related concept '
      question.delete
      next
    end
    category = concept.category
    # 1 - category level 1 0-999
    # 2 - category level 2 0-999
    # O - concept order within category 0-99 999
    # 111 22 2OO OOO
    order = 0
    if !category.level_1_order.nil?
      order += category.level_1_order * 100000000
    end
    if !category.level_2_order.nil?
      order += category.level_2_order * 100000
    end
    order += concept.order_in_category

    question.update_attribute(:sort_order,order)
  end
end


def parse_option_lists doc
  puts "parse_option_lists"
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
      delete_data
      create_forms
      parse_categories(doc)
      parse_concepts(doc)
      parse_questions doc
      parse_option_lists doc
    end

    def check_and_fix_assessments
        assessments_with_duplicate_answers = []
        Assessment.all.each do |a|
          if !a.answers_unique?
            assessments_with_duplicate_answers << a
          end
          a.answers_exist_in_form?
        end
      assessments_with_duplicate_answers.each do |a|
        fix_duplicate_answers a
      end
    end

    def fix_duplicate_answers a
      a.form.questions.each do |q|
        question_answers = a.answers.where(:question_id => q._id)
        if question_answers.size > 1
          answers_ids = []
          question_answers[0]
          for i in 1..question_answers.size-1 do
            if question_answers[0].value_to_s != question_answers[i].value_to_s
              raise '!!! Duplicate answers in assessment :'  + a._id + '  is not equal '
              + question_answers[0].value_to_s + '!= ' + question_answers[i].value_to_s
            end
            answers_ids << question_answers[i]._id
          end
          answers_ids.each do |id|
            a.answers.find(id).delete
            puts 'duplicate answer removed'
          end
        end
      end
    end


    desc "Update data from questions spreadsheet"
    task update_questions: :environment do
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
        #setup_question_order
    end

    desc "Perfoms some data checks"
    task check_data: :environment do
      check_and_fix_assessments
    end
end