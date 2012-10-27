module PatientHelper

  def patient_info_array patient
    info_fields_hash = Hash.new
    info_fields_hash['Medicare number'] = 'medicare_card_number'
    info_fields_hash['Medicare identifier'] = 'medicare_card_number_identifier'
    info_fields_hash['IHI'] = 'individual_healthcare_identifier'
    info_fields_hash['NHS number'] = 'nhs_number'
    info_fields_hash['Social security number'] = 'social_security_number'

    #- medicare_patient_number = @patient.get_answer_value_from_patient_form "medicare_card_number_identifier"
    #- if medicare_patient_number
    #    <b>Medicare card patient identifier:</b> #{medicare_patient_number}

    result = []
    #Medicare number: IF NOT BLANK
    #Medicare identifier: IF NOT BLANK
    #NHS number: IF NOT BLANK
    #Social security number: IF NOT BLANK
    info_fields_hash.each_key do |key|
      value = patient.get_answer_value_from_patient_form info_fields_hash[key]
      if !value.nil? && !value.blank?
        result << {name: key,value: value}
      end
    end
    result
  end
end
