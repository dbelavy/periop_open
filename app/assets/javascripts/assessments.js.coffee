# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  dob_name = "patient_dob"
  formSelector = 'form.assessment'
  questionsSelector = formSelector  + ' .question'

  #onChange fire event with shortname
  $(document).delegate(questionsSelector, 'change',
  ->
    shortname = $(this).data("short-name")
    newValue = $(this).val()
    if shortname == dob_name
      shortname = "patient_age"
    event = $.Event('question.' + shortname)
    $(formSelector).trigger(event,newValue)
  )

  calculateAge = () ->
    day = $('[data-short-name=' + dob_name + ']').eq(0).val()
    month = $('[data-short-name='+ dob_name+ ']').eq(1).val() - 1
    year = $('[data-short-name=' + dob_name + ']').eq(2).val()
    today=new Date();
    age = today.getFullYear()-year;
    if(today.getMonth()<month || (today.getMonth()==month && today.getDate()<day))
      age--
    age

  condition =
    getConditions: ($el) ->
      result =null
      condStr =  $el.data('condition')
      if condStr != null && condStr != ""
        result = condition.parseOperation(condStr,"and")
        if result == null
          result = condition.parseOperation(condStr,"or")
        if result == null
          result = new Object()
          #          special case for atomic condition
          result.op = "and"
          result.condArr = [condition.getAtomicConditions(condStr)]
      return result

    parseOperation: (condStr, operation) ->
      if condStr.search(" " + operation + " ") != -1
        condArr = []
        arr = condStr.split(" " + operation + " ")
        for atomicStr in arr
          atomicHash = condition.getAtomicConditions(atomicStr)
          condArr.push(atomicHash)
        result = new Object()
        result.op = operation
        result.condArr = condArr
        return result
      else
        return null

    getAtomicConditions: (str) ->
      arr = str.split(" ")
      if arr.length == 3
        shortname = arr[0]
        return {shortname: shortname,operation: arr[1],value: arr[2]}
      else
        alert 'atomic condition not implemented yet :' + str
      return null
    checkAtomic: (conditionHash) ->
      if conditionHash != null
        if conditionHash.shortname == 'patient_age'
          value =  calculateAge()
        else
          value = $('[data-short-name=\"' +conditionHash.shortname + '\"]').val()
          if (value)
            value = value.toLowerCase()
        if conditionHash.operation == "="
          return value == conditionHash.value
        else if conditionHash.operation == "<"
          return value < conditionHash.value
        else if conditionHash.operation == ">"
          return value > conditionHash.value
        else if conditionHash.operation == "!="
          return value != conditionHash.value
        else
          alert "operation not implemented" + JSON.stringify(conditionHash)

    checkAndApply: ($input) ->
      condObj = condition.getConditions($input)
      formDisabled = $input.parents('form').attr('disabled') == 'disabled'
      if condObj != null
        if (condObj.op == "or")
          result = false
        else
          result = true
        for condHash in condObj.condArr
          if (condObj.op == "or")
            result = result || condition.checkAtomic(condHash)
          else
            result = result && condition.checkAtomic(condHash)
        if $input.hasClass("question_details")
          if (result)
            $input.parents('.control-group').show("slow")
            if !formDisabled
              $input.removeAttr("disabled")
          else
            $input.parents('.control-group').hide("slow")
            $input.attr("disabled","disabled")
        else if $input.hasClass("question")
          if (result)
            $input.parents('fieldset').show("slow")
            if !formDisabled
              $input.removeAttr("disabled")
          else
            $input.parents('fieldset').hide("slow")
            $input.attr("disabled","disabled")


  window.condition =condition
  $(questionsSelector).each(
     ->
       condObj = condition.getConditions($(this))
       if condObj != null
         for condHash in condObj.condArr
           $(formSelector).bind('question.' + condHash.shortname,{input: this}
             (event) ->
               input = event.data.input
               condition.checkAndApply($(input))
             )
           true
           condition.checkAndApply($(this))

    )