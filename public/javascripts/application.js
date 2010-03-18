var ResizingTextArea = Class.create();

ResizingTextArea.prototype = {
    defaultRows: 1,

    initialize: function(field)
    {
        this.defaultRows = Math.max(field.rows, 1);
        this.resizeNeeded = this.resizeNeeded.bindAsEventListener(this);
        Event.observe(field, "click", this.resizeNeeded);
        Event.observe(field, "keyup", this.resizeNeeded);
    },

    resizeNeeded: function(event)
    {
        var t = Event.element(event);
        var lines = t.value.split('\n');
        var newRows = lines.length + 1;
        var oldRows = t.rows;
        for (var i = 0; i < lines.length; i++)
        {
            var line = lines[i];
            if (line.length >= t.cols) newRows += Math.floor(line.length / t.cols);
        }
        if (newRows > t.rows) t.rows = newRows;
        if (newRows < t.rows) t.rows = Math.max(this.defaultRows, newRows);
    }
}


var App = {
  toggleNotes: function(clear) {
    if ($('notes').visible()) {
      App.hideNotes(true);
    } else {
      App.showNotes();
    }
  },
  
  hideNotes: function(clear) {
    $('notes').hide();
    if (clear==true) {
      $('spot_notes').value = '';
    }
    $('toggle_notes').show();
  },

  showNotes: function() {
    $('notes').show();
    $('toggle_notes').hide();
  },

	showPass: function() {
		$('pass_t').show();
		$('pass_d').show();
	},
	
	hidePass: function() {
		$('pass_t').hide();
		$('pass_d').hide();
	},
	
	passState: function() {
		var active = $("spot_open").getValue();
		var pass = $("pass");
		(active == "false") ? App.showPass() : App.hidePass();
	}
  
};


document.observe("dom:loaded", function() {

	Event.observe($("city"), "change", function() {
		city = $("city");
		location.href = '	/cities/' + city.getValue();
	});

});