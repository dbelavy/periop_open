# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
        $('#patients').dataTable
          sPaginationType: "bootstrap"
          sWrapper: "dataTables_wrapper form-inline"
          sDom: "<'row pull-right'<'span2 pull-right'l><'span4  pull-right'f>r>t<'row'<'span6'i><'span6'p>>"
          bProcessing: true
          bServerSide: true
          sAjaxSource: $('#patients').data('source')


