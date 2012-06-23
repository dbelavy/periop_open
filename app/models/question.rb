class Question
  include Mongoid::Document

  PATIENT = :patient
  PROFESSIONAL = :professional

  field :question_type, :type => String
  field :condition, :type => String
  field :short_name, :type => String
  field :input_type, :type => String, :default => 'select'
  field :option_list_name, :type =>  String
  field :person_role, :type => Array

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
    OptionList.where(:name => self[:option_list_name])
  end
end
