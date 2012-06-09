class Question
  include Mongoid::Document

  PATIENT = :patient
  PROFESSIONAL = :professional

  field :question_type, :type => String
  field :conditions, :type => String
  field :short_name, :type => String
  field :input_type, :type => String
  field :option_list, :type => String
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
    question = Question.create! args
    concept = Concept.where( :name => args[:concept]).first
    question.concept= concept
    question.save!
  end
end
