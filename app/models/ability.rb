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
      user ||= User.new # guest user (not logged in)
      if user.admin?
        Rails.logger.debug 'admin user'
        can :read, Patient
        can :manage, Professional
        can :manage, User
        can :manage, Question
      elsif user.professional?
        Rails.logger.debug 'professional user'
        can :manage, Patient
        can :manage, Assessment
        can :read, :all
      else
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
