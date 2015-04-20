# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "click", ".show_add_page_form", ->
  if $("#add_page_form").css("display") is "none"
    $("#add_page_form").slideDown "slow", ->
      $("#add_page").toggle()
      $("#cancel_add_page").toggle()
      return false
  else
    $("#add_page_form").slideUp "slow", ->
      $("#add_page").toggle()
      $("#cancel_add_page").toggle()
      return false

$ ->
  group = $('ol.sortable_pages').sortable(
    group: 'sortable_pages'
    onDrop: (item, container, _super) ->
      data = group.sortable('serialize').get()
      jsonString = JSON.stringify(data, null, ' ')
      document.getElementById('reorder_submission').value = jsonString
      _super item, container
      return
  )
  return
