require Rails.root.join('spec', 'helpers.rb')
require 'rubygems' #so it can load gems


def parse_concepts(doc)
  all_names = Concept.all.map{|c| c.name}
  puts "parse_concepts"
  # TODO typo in spreadsheet
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
  # only to be used on development
  puts 'delete_data!!!'
  if !Rails.dev?
    raise "you are going to delete all data"
  end
  #Form.delete_all
  #Category.delete_all
  #Concept.delete_all
  #Question.delete_all
end

def create_forms
  puts 'create_forms'
  Form.find_or_create_by(name: Form::NEW_PATIENT).update_attributes(person_role: [Question::PROFESSIONAL])
  Form.find_or_create_by(name: Form::PATIENT_ASSESSMENT).update_attributes(person_role: [Question::PATIENT])
  Form.find_or_create_by(name: Form::CLINIC_ASSESSMENT).update_attributes(person_role: [Question::PROFESSIONAL])
  Form.find_or_create_by(name: Form::NEW_OPERATION).update_attributes(person_role: [Question::PROFESSIONAL])
  Form.find_or_create_by(name: Form::QUICK_NOTE_ASSESSMENT).update_attributes(person_role: [Question::PROFESSIONAL])

  @custom_patient_assessments_cols.keys.each do |name|
    professional = Professional.find_by_name name
    if professional.nil?
      puts ('Skipping questionaire for ' + name + ' doctor not found')
    else
      puts 'Find  or create custom patient form for doctor ' + name
      Form.find_or_create_by(name: Form::PATIENT_ASSESSMENT,professional_id: professional._id).update_attributes(person_role: [Question::PATIENT])
    end
  end
end

def column_for doc,name
  1.upto doc.last_column do |col|
    if doc.cell(1,col).to_s == name
      return col
    end
  end
end

def display_deleted_questions(question_ids)
  if (question_ids.size > 0)
    puts '!!! following questions now not exist question_id\'s: ' + question_ids.to_s

    question_ids.each do |id|
      Question.where(question_id: id).each do |q|
        puts 'question : ' + q.inspect
      end
    end
    puts 'end of deleted questions'
  end
end


def prepare_condition(condition)
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

  condition.gsub!("=", "eq")
  condition.gsub!("!=", "neq")
  condition.gsub!("<", "less")
  condition.gsub!(">", "more")
  end
  condition
end

def parse_questions doc
  puts 'parse_questions'
  doc.default_sheet = 'Questions'
  new_patient_form = Form.where(name: Form::NEW_PATIENT).first
  new_patient_form.clear_questions

  default_patient_form = Form.where(name: Form::PATIENT_ASSESSMENT).first
  default_patient_form.clear_questions

  clinic_form = Form.where(name: Form::CLINIC_ASSESSMENT).first
  clinic_form.clear_questions

  note_form = Form.where(name: Form::QUICK_NOTE_ASSESSMENT).first
  note_form.clear_questions

  operation_form = Form.where(name: Form::NEW_OPERATION).first
  operation_form.clear_questions

  @custom_patient_assessments_cols.keys.each do |name|
    Form.patient_form(Professional.name_to_slug(name)).clear_questions
  end

  used_in_new_patient_col = column_for(doc,"New_Patient_Form")
  used_in_patient_assessment_col = column_for(doc,"Question used in patient assessment")
  used_in_professional_assessment_col = column_for(doc,"Professional_assessment")
  used_in_new_operation_assessment_col = column_for(doc,"New_Operation_Form")
  used_in_quick_note_assessment_col = column_for(doc,"Quick_note")

  required_col = column_for(doc,"Required_field")

  validation_col = column_for(doc,"Validation_criteria")

  all_question_ids = Question.all.map{|q| q.question_id}

  2.upto(doc.last_row) do |line|
    if doc.cell(line, "A").nil?
      next
    end

    #if doc.cell(line, "G").include? "_section"
    #  next
    #end

    condition = prepare_condition(doc.cell(line, "F"))

    check_conditon condition

    ask_details_criteria = doc.cell(line, "K").downcase if !doc.cell(line, "K").nil?
    ask_details_criteria ="all" if ask_details_criteria == "any answer"

    question_id = doc.cell(line, "C")
    all_question_ids.delete(question_id)

    if(!Question.exists?(:conditions => {question_id: question_id}))
      puts 'creating new questions : ' + question_id.to_s
    end

    question = Question.find_or_create_by(question_id: question_id)
    option_list_name = doc.cell(line, "H")
    if !@option_list_names.include? option_list_name
      puts '!! option_list_name : ' + option_list_name + ' for question :' + doc.cell(line, "E") + ' not exist'
    end
    #puts "overall pos: " + doc.cell(line, "A").to_s
    question.update_attributes!(question_id: question_id,
                                display_name: doc.cell(line, "E"),
                                condition: condition,
                                input_type: doc.cell(line, "G"),
                                text_length: doc.cell(line, "I"),
                                ask_details: doc.cell(line, "J"),
                                ask_details_criteria: ask_details_criteria,
                                option_list_name: option_list_name,
                                validation_criteria: doc.cell(line, validation_col),
                                sort_order: doc.cell(line, "A").to_i,
                                required: doc.cell(line,required_col)
                                )

    concept_name_cell = doc.cell(line, "D")
    if !concept_name_cell.nil? && !concept_name_cell.blank?
      concept_name = concept_name_cell.downcase
      question.concept = Concept.where(name: concept_name).first
      question.save!
      if question.concept.nil?
        raise "Not found concept " + concept_name
        puts "Not found concept " + concept_name
      end
    end

    # used in patient assessment
    if doc.cell(line, used_in_patient_assessment_col)
      default_patient_form.questions.push question
    end
    if doc.cell(line, used_in_new_patient_col)
      new_patient_form.questions.push question
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

    @custom_patient_assessments_cols.keys.each do |name|
      column = @custom_patient_assessments_cols[name]
      if doc.cell(line, column)
        form = Form.patient_form(Professional.name_to_slug(name))
        puts 'adding question : ' + question.display_name + ' for doctor ' + name + ' form : ' + form._id.to_s
        form.questions.push(question)
      end
    end

    #puts 'created question: ' + question.to_s
  end

  @custom_patient_assessments_cols.keys.each do |name|
    puts 'patient form for doctor ' + name + "have " + Form.patient_form(Professional.name_to_slug(name)).questions.size.to_s + " questions"
  end

  display_deleted_questions(all_question_ids)
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
  @option_list_names = []
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
    @option_list_names << option_list.name
    #puts 'created option List: ' + option_list.to_s
  end
end


  namespace :db do

    def check_and_fix_assessments
        assessments_with_duplicate_answers = []
        @@alternate_questions = {}
        @updated_count = 0
        Assessment.all.each do |a|
          if !a.answers_unique?
            assessments_with_duplicate_answers << a
          end
          check_and_fix_question_not_exist_in_form a
        end
        puts 'total updated question number : ' +  @updated_count.to_s
      assessments_with_duplicate_answers.each do |a|
        fix_duplicate_answers a
      end
    end


    def check_and_fix_question_not_exist_in_form assessment
      form = assessment.form
      @@alternate_questions[form] = @@alternate_questions[form] || {}
      questions_array = form.questions.map {|q| q._id}
      assessment.answers.each  do |ans|
        if ans.question_id.nil?
          result = false
          log_error '!!! assessment : ' + assessment._id.to_s + ' has answer that does not have question id ' +  ans._id.to_s
        elsif !questions_array.include? ans.question_id
          # find analogue question
          if (@@alternate_questions[form][ans.question_id].nil?)
            if !Question.where(_id: ans.question_id).exists?
              log_error 'Question : ' + ans.question_id.to_s + ' not exist in DB !!! Form :' + form._id.to_s  + ' form.name ' + form.name
                        ' answer : ' + ans._id.to_s + ' answer.value : ' + ans.value_to_s + 'Patient ' + assessment.patient.to_s
              next
            end
            question = Question.find(ans.question_id)
            concept = question.concept
            question_with_same_concept = form.questions.by_concept(concept)
            if question_with_same_concept.nil?
              log_error 'no alternate question with concept : ' +concept.name + ' exist in form :' + form._id.to_s + ' answer.value : ' + ans.value_to_s
              @@alternate_questions[form][ans.question_id] = -1
              next
            else
              @@alternate_questions[form][ans.question_id] = question_with_same_concept._id
            end
          end
          if @@alternate_questions[form][ans.question_id] != -1
            log_warn 'changing q._id :'  + ans.question_id.to_s + ' => ' + @@alternate_questions[form][ans.question_id].to_s
            @updated_count = @updated_count + 1
            ans.update_attribute(:question_id ,@@alternate_questions[form][ans.question_id])
          end
        end
      end
    end

    def fix_duplicate_answers a
      a.form.questions.each do |q|
        question_answers = a.answers.where(:question_id => q._id)
        if question_answers.size > 1
          empty_answers_ids = []
          non_empty_answers_ids = []
            for i in 0..question_answers.size-1 do
              if !question_answers[i].value_to_s.blank?
                empty_answers_ids << question_answers[i]._id
              else
                non_empty_answers_ids << question_answers[i]._id
              end
            end

          duplicate_answers_ids = []

          if non_empty_answers_ids.size > 1
            prev_answer = nil
            for i in 0..non_empty_answers_ids.size-1 do
              if !prev_answer.nil?
                if (a.answers.find(non_empty_answers_ids[i]).value_to_s != prev_answer)
                  raise 'duplicate not equals answers found' + a.answers.find(non_empty_answers_ids[i]).inspect
                else
                  duplicate_answers_ids << non_empty_answers_ids[i]
                end
              else
                prev_answer = a.answers.find(non_empty_answers_ids[i]).value_to_s
              end

            end
          end
          empty_answers_ids.each do |id|
            a.answers.find(id).delete
            puts 'empty answer removed'
          end
          duplicate_answers_ids.each do |id|
            a.answers.find(id).delete
            puts 'duplicate answer removed'
          end
        end
      end
    end


    desc "Update data from questions spreadsheet"
    task update_questions: :environment do
        require 'roo'
        #doc = Excel.new("./spreadsheet/Question_properties.xls")
        doc = open_doc
        @custom_patient_assessments_cols = populate_custom_patient_assessments_cols doc
        create_forms
        parse_categories(doc)
        parse_concepts(doc)
        parse_option_lists doc
        parse_questions doc
      check_sections
      #setup_question_order
    end

    desc "Perfoms some data checks"
    task check_and_fix_data: :environment do
      check_and_fix_assessments
    end

    def log_error message
      puts message
      Rails.logger.error message
    end

    def log_warn message
      puts message
      Rails.logger.warn message
    end

    def open_doc
      Openoffice.new("./spreadsheet/Question_properties_OO.ods")
    end


    private

  def populate_custom_patient_assessments_cols doc
    doc.default_sheet = 'Questions'
    result = {}
    done = false
    # start column position of doctors custom patient assessment
    column = column_for(doc,"Dr David Belavy")
    while !done do
      doctor_name = doc.cell(1, column)
      if !doctor_name.nil? && (!doctor_name.empty?)
        professional = Professional.find_by_name doctor_name
        if professional.nil?
          puts ('Skipping questionaire for ' + doctor_name + ' doctor not found')
        else
          result[doctor_name]=column
        end
        column +=1
      else
        done = true
      end
    end
    puts ' doctor\'s patitent assessments : '  + result.inspect
    result
  end
end
