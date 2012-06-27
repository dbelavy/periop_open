# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

  formSelector = 'form.assessment'
  questionsSelector = formSelector  + ' .question'

  #onChange fire event with shortname
  $(document).delegate(questionsSelector, 'change',
  ->
    shortname = $(this).data("short-name")
    newValue = $(this).val()
    if shortname == "dob"
      shortname = "age"
    event = $.Event('question.' + shortname)
    $(formSelector).trigger(event,[newValue])
  )

  calculateAge = () ->
    day = $('[data-short-name="dob"]').eq(0).val()
    month = $('[data-short-name="dob"]').eq(1).val() - 1
    year = $('[data-short-name="dob"]').eq(2).val()
    today=new Date();
    age = today.getFullYear()-year;
    if(today.getMonth()<month || (today.getMonth()==month && today.getDate()<day))
      age--
    age


#TODO sample conditions:  gender = female and age > 14 and age < 45
  # gender = female , male
  # gender = female
  condition =
    getConditions: ($el) ->
      conditionStr =  $el.data('condition')
      if conditionStr  != null
        arr = conditionStr.split(" ")
        if arr.length == 3
          shortname = arr[0]
          return {shortname: shortname,operation: arr[1],value: arr[2]}
        else alert 'not implemented yet :' + condition
      else null
    check: (conditionHash) ->
      if conditionHash != null
        if conditionHash.shortname == 'age'
         value =  calculateAge()
        else
          value = $('[data-short-name=\"' +conditionHash.shortname + '\"]').val()
          if (value)
            value = value.toLowerCase()
        if conditionHash.operation == "="
          return value == conditionHash.value
        else if conditionHash.operation == "<"
         return value < conditionHash.value
    checkAndApply: ($input) ->
        condHash = condition.getConditions($input)
        if condHash != null
          result = condition.check(condHash)
          if (result)
            $input.parents('.control-group').show()
            $input.removeAttr("disabled")
          else
            $input.parents('.control-group').hide()
            $input.attr("disabled","disabled")

  $(questionsSelector).each(
   ->
     condHash = condition.getConditions($(this))
     if condHash
       $(formSelector).bind('question.' + condHash.shortname,{input: this}
         (event) ->
           input = event.data.input
           condition.checkAndApply($(input))
         )
       true
     condition.checkAndApply($(this))
  )
  #.bind( eventType [, eventData], handler(eventObject) )
