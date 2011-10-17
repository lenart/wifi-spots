$().ready(function() {

  $('#spot_open').change(function() {
    $('#pass_t').toggle()
    $('#pass_d').toggle()
  })

}) // $().ready()

$.extend({
  togglePass: function() {
    $('#pass_t').toggle()
    $('#pass_d').toggle()
  },

  hideNotes: function() {
    $("#notes").show()
    $("#toggle_notes").hide()
  }
}) // $.extend()