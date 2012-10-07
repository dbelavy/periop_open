class UserObserver < Mongoid::Observer

  def after_save(user)
    if user.professional?
      Patient.all.each do |patient|
        patient.update_values
      end
    end
  end
end
