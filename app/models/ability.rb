class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    Rails.logger.debug 'initialize ability for : ' + user.to_s
    if user.instance_of? Patient

      can :read, :question
      can :show, Patient do |patient|
        result = patient.eql? user
        Rails.logger.debug 'current patient: ' + patient.name + ' authoirzed: ' + result.to_s
        result
      end
    elsif user.nil? || (user.instance_of? User)
      user ||= User.new # create guest user (not logged in)
      if user.admin?
        Rails.logger.debug 'admin user'
        can :read, Patient
        can :manage, Professional
        can :manage, User
        can [:unassigned,:read], Assessment
        can :manage, Question
      elsif user.professional?
        professional_ids = user.professional.has_access_to
        #Rails.logger.debug 'professional user : has access to ' + professional_ids.to_s
        #can :manage, Patient
        can :read, User, :_id => user._id
        can :read, Professional, :user_id => user._id
        professional_ids.each do |id|
          Rails.logger.debug 'checking ability for id => ' + id.inspect
          can [:unassigned,:assign,:unassign], Assessment,:anesthetist_id => id.to_s
          can :manage, Patient, :anesthetist_id => id
        end
        can [:read,:edit,:update,:destroy], Assessment do |assessment|
          #result = (professional_ids.include? assessment.anesthetist_id.to_s )
          result = (professional_ids.include? BSON::ObjectId(assessment.anesthetist_id) )
          if !assessment.patient.nil?
            result = result || (professional_ids.include? BSON::ObjectId(assessment.patient.anesthetist_id))
          end
          result
        end
        can [:create,:operation_assessment_form,:clinician_assessment_form,:note_assessment_form],Assessment
        can [:loading_screen],Assessment
        #can :create, Patient
      else
        # if guest user
       can [:patient_assessment_form,:update_patient_assessment],Assessment
      end
    end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
