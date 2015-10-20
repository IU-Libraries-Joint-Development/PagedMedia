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

$ ->
  group = $('ol.holding_pages').sortable(
    group: 'sortable_pages'
  )
  return

$ ->
  $('#move_to_back').click ->
    $('ol.holding_pages > li').appendTo('ol#sortable_pages')
    group = $('ol.sortable_pages')
    data = group.sortable('serialize').get()
    jsonString = JSON.stringify(data, null, ' ')
    document.getElementById('reorder_submission').value = jsonString
    return false
  
$ ->
  $('#move_to_front').click ->
    $('ol.holding_pages > li').prependTo('ol#sortable_pages')
    group = $('ol.sortable_pages')
    data = group.sortable('serialize').get()
    jsonString = JSON.stringify(data, null, ' ')
    document.getElementById('reorder_submission').value = jsonString
    return false

$ ->
  $('.sortable_save').click ->
    items = $("ol.holding_pages li").length
    if (items > 0)
      alert("Holding Pen must be empty before reordering.")
      return false
    else
      return true

# Source : http://jsfiddle.net/fengelz/28x7Y/
$ ->
  $('.custom-upload input[type=file]').change ->
      $(this).next().find('input').val($(this).val())
 
