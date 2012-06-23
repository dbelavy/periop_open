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
    event = $.Event('question.' + shortname)
    $(formSelector).trigger(event,[newValue])
  )
  #TODO sample conditions:  gender = female and age > 14 and age < 45
  # gender = female , male
  # gender = female
  condition =
    getConditions: ($el) ->
      conditionStr =  $el.data('condition')
      if conditionStr  != null
        arr = conditionStr.split(" ")
        if arr.length == 3
          return {shortname: arr[0],operation: arr[1],value: arr[2]}
        else alert 'not implemented yet :' + condition

    check: (conditionHash) ->
      if conditionHash.shortname == 'age'
#       value =  TODO
      else
        value = $('[data-short-name=\"' +conditionHash.shortname + '\"]').val().toLowerCase()
      if conditionHash.operation == "="
        return value == conditionHash.value
      else if conditionHash.operation == "<"
       return value < conditionHash.value
    getAndCheck: ($input) ->
        condHash = condition.getConditions($input)
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
           condition.getAndCheck($(input))
         )
       true
  )
  #.bind( eventType [, eventData], handler(eventObject) )
