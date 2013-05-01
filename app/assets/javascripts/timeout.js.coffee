# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ajaxError (e,error) ->
  if error.status == 401
    console.log 'session timeout'
    location.reload()