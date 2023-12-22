var selectedElement = -1;
var tickets = [
	// { "title": "Balfasz voltál...", "cost": 50, "id": 1, "timestamp": 1540494994, "account": 25 },
];

function loadTickets() {
	$('#content').children().each(function() {
		this.remove();
	});
	$.each(tickets, function(i, v) {
		var date = new Date(v["timestamp"]*1000);
		var years = date.getFullYear();
		var month = "0" + (date.getMonth()+1);
		var days = "0" + (date.getDay()+21);
		var hours = date.getHours();
		var minutes = "0" + date.getMinutes();
		var seconds = "0" + date.getSeconds();
		$('#content').append("<div id='"+i+"' class='panelElement' name='panelElement'><font size='0.25'>Határidő:</font> "+tickets[i]["date"]+"</div>")
	});
	
	if(tickets.length <= 0) {
		mta.triggerEvent("closePanel");
	}
}

function receiveTickets(t) {
	t = t[0];
	tickets = t;
	
	loadTickets();
}

// $(document).ready(function() {
	// loadTickets();
// });

$(document).mouseover(function(e){
	if($(e.target).attr('name') == "panelElement") {
		$(document).on('mousemove', function(ev){
			var id = $(ev.target).attr("id");
			$('#tooltip').css({
			   left:  ev.pageX+10,
			   top:   ev.pageY+10,
			   display: "block",
			});
			$('#tooltipText').html("<font color='lightblue'>"+tickets[id]["title"]+"</font>");
			$('#tooltipCost').html("Befizetendő: <font color='orange'>$</font>"+tickets[id]["cost"]);
		});
	} else {
		$(document).unbind("mousemove");
		$('#tooltip').css({
		   display: "none"
		});
	}
});

$(document).click(function(e) {
	var element = $(e.target);
	if(element.attr('name') == "panelElement") {
		var id = element.attr("id");
		if(selectedElement != id) {
			if(selectedElement > -1) {
				$('#'+selectedElement).removeClass("activeElement");
			}
			selectedElement = parseInt(id);
			element.addClass("activeElement");
			$(document).unbind("mousemove");
			$('#tooltip').css({
				display: "none"
			});
			$('#payButton').css({
				display: "block"
			});
		}
	} else {
		if(selectedElement > -1) {
			$('#'+selectedElement).removeClass("activeElement");
			selectedElement = -1
			$('#payButton').css({
				display: "none"
			});
		}
	}
});

function paySelected() {
	if(selectedElement > -1) {	
		mta.triggerEvent("payTicket", selectedElement+1);
	}
}

function payAll() {
	mta.triggerEvent("payAllTicket");
}