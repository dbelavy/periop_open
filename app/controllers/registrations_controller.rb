class RegistrationsController < Devise::RegistrationsController
    def new
      super
      #@user.assign_role(User::PROFESSIONAL)

    end

    def build_resource(hash=nil)
      super(hash)
      if @user.professional.nil?
        @user.professional = Professional.new
        @user.professional.speciality= Professional::ANESTHETIST
        @user.user_role = User::PROFESSIONAL
      end
    end

    def update
      super
    end
end