class Question
  include Mongoid::Document

  PATIENT = :patient
  PROFESSIONAL = :professional

  field :question_id, :type => Integer
  field :condition, :type => String
  field :short_name, :type => String
  field :display_name, :type => String
  field :input_type, :type => String, :default => 'OneOption'
  field :option_list_name, :type =>  String
  field :text_length, :type =>  Integer
  field :ask_details, :type =>  String
  field :validation_criteria, :type =>  String
  field :ask_details_criteria, :type =>  String


  belongs_to :concept
  #field registered, :type => Date

  #def person_role= arg
  #  if !arg.instance_of?Array
  #    person_role = [arg]
  #  else
  #    person_role  = arg
  #  end
  #end

  def self.build_with_concept( args )
    if args[:option_list_name].nil? && (args[:input_type].nil? ||args[:input_type] == 'select')
      if args[:person_role] == [Question::PATIENT]
        args[:option_list_name] = "Y_N_U_Patient"
      elsif args[:person_role] == [Question::PROFESSIONAL]
        args[:option_list_name] = "Y_N_U_Clinician"
      else
        raise 'default  option_list_name not available, please provide directly' + args.to_s
      end
    end
    question = Question.create! args
    concept = Concept.where( :name => args[:concept]).first

    question.concept= concept
    question.update_attribute(:short_name ,concept.display_name)
    question.save!
  end

  def condition= conditionStr
    if !conditionStr.nil?
      conditionStr = conditionStr.to_s.downcase
      if conditionStr[0..2] == "if "
        conditionStr = conditionStr[3..conditionStr.length]
      end
    end
    self[:condition] = conditionStr
  end

  def option_list
    OptionList.where(:name => self[:option_list_name]).asc(:order_number)
  end

  def details_criteria
    if !concept.nil? && !ask_details_criteria.nil?
      concept.name.downcase + " = " + ask_details_criteria
    end
  end


  def start_year
    if input_type == "Date"
      if !validation_criteria.nil?
        if validation_criteria.downcase == "past"
          return Date.today.year - 120
        elsif validation_criteria.downcase == "future"
          return Date.today.year
        end
      end
    end
  end


  def end_year
    if input_type == "Date"
      if !validation_criteria.nil?
        if validation_criteria.downcase == "past"
          return Date.today.year
        elsif validation_criteria.downcase == "future"
          return Date.today.year + 100
        end
      end
    end
  end
end
