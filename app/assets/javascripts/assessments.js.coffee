# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  animation_speed = 'fast'
  dob_name = "patient_dob"
  formSelector = 'form.assessment'
  questionsSelector = formSelector  + ' .question'
  questionsSelector = formSelector  + ' [data-condition]'

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
          value = $('[data-short-name=\"' +conditionHash.shortname + '\"].question').val()
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

    checkAndApply: ($el) ->
      condObj = condition.getConditions($el)
      formDisabled = $el.parents('form').attr('disabled') == 'disabled'
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
        if $el.hasClass("question_details")
          if (result)
            $el.parents('.control-group').show(animation_speed)
            if !formDisabled
              $el.removeAttr("disabled")
          else
            $el.parents('.control-group').hide(animation_speed)
            $el.attr("disabled","disabled")
        else if $el.hasClass("question")
          if (result)
            $el.parents('fieldset').show(animation_speed)
            if !formDisabled
              $el.removeAttr("disabled")
          else
            $el.parents('fieldset').hide(animation_speed)
            $el.attr("disabled","disabled")
        else if $el.is("fieldset")
          if (result)
            $el.show(animation_speed)
            if !formDisabled
              $el.find('input').removeAttr("disabled")
          else
            $el.hide(animation_speed)
            $el.find('input').attr("disabled","disabled")


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

jQuery ->
        $('.datepicker').datepicker
          format: "dd-mm-yyyy"
          autoclose: true

