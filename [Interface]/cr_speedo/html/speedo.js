var index_l = false;
var index_l_active = false;
var index_r = false;
var index_r_active = false;
var currentGear = false;
var engine = false;
var vehicleHealth = 1000;
var tOut = false;
var audioElement = null;
var isInVehicle = false;

function getVehicleStateColor() {
	if(vehicleHealth >= 750) {
		return "rgba(0, 255, 0, 0.7)";
	} else if(vehicleHealth >= 600) {
		return "rgba(255, 150, 51, 0.7)";
	} else if(vehicleHealth >= 400) {
		return "rgba(150, 0, 0, 0.7)";
	} else if(vehicleHealth < 400) {
		return "rgba(255, 0, 0, 0.7)";
	}
}

function updateSpeed(speed) {
	if(parseInt(speed) < 10) {
		speed = "00"+speed;
	} else if(parseInt(speed) < 100) {
		speed = "0"+speed;
	}
	
	$("#speed").html(speed.toString());
	if(engine) {
		var val = (0.85/433)*(parseInt(speed)+34);
		if(val > 0.837) {
			val = 0.837;
		}
		$('.circle').circleProgress({
			value: val,
			startAngle: 2.08,
			animation: false,
			size: 231,
			emptyFill: "rgba(0, 0, 0, 0)",
			thickness: 7,
			fill: {
			  gradient: ["rgba(204, 139, 41, 1)", "rgba(204, 139, 41, 1)", "rgba(204, 57, 41, 1)", "rgba(204, 57, 41, 1)"]
			}
		});
	} else {
		if(!tOut) {
			$('.circle').circleProgress({
				value: 0,
				startAngle: 2.08,
				animation: {duration: 1000, easing: "circleProgressEasing"},
				size: 231,
				emptyFill: "rgba(0, 0, 0, 0)",
				thickness: 7,
				fill: {
				  gradient: ["rgba(204, 139, 41, 1)", "rgba(204, 139, 41, 1)", "rgba(204, 57, 41, 1)", "rgba(204, 57, 41, 1)"]
				}
			});
		}
		
	}
	if(parseInt(speed) == 0) {
		$("#gear").html("N");
	}  else if(speed > 0 && $("#gear").html() == "N") {
		$("#gear").html("1");
	}
}

var noFlood = false;
function playIndex() {
	if(isInVehicle) {
		if(!noFlood) {
			audioElement.currentTime = 0;
			audioElement.play();
			noFlood = true;
			setTimeout(function() {
				noFlood = false;
			}, 200);
		}
	} else {
		clearInterval(index_l);
		clearInterval(index_r);
		$("#index_l").removeClass("active_index_l");
		$("#index_r").removeClass("active_index_r");
		index_l_active = false;
		index_r_active = false;
	}
	
}

function updateIndexes(left, right) {
	$("#index_l").removeClass("active_index_l");
	$("#index_r").removeClass("active_index_r");
	index_l_active = false;
	index_r_active = false;
	clearInterval(index_l);
	clearInterval(index_r);
	if(parseInt(left) == 1) {
		$("#index_l").addClass("active_index_l");
		index_l_active = true;
		index_l = setInterval(function(){
			if(!index_l_active) {
				$("#index_l").addClass("active_index_l");
				index_l_active = true;
				playIndex();
			} else {
				$("#index_l").removeClass("active_index_l");
				index_l_active = false;
			}
		}, 300);
	} else if(index_l) {
		$("#index_l").removeClass("active_index_l");
		index_r_active = false;
		clearInterval(index_l);
	}
	if(parseInt(right) == 1) {
		$("#index_r").addClass("active_index_r");
		index_r_active = true;
		index_r = setInterval(function(){
			if(!index_r_active) {
				$("#index_r").addClass("active_index_r");
				index_r_active = true;
				playIndex();
			} else {
				$("#index_r").removeClass("active_index_r");
				index_r_active = false;
			}
		}, 300);
	} else if(index_r) {
		$("#index_r").removeClass("active_index_r");
		index_r_active = false;
		clearInterval(index_r);
	}
}

function updateEngine(state) {
	if(parseInt(state) == 1) {
		engine = true;
		$("#engine").addClass("active_engine");
	} else {
		engine = false;
		$("#engine").removeClass("active_engine");
	}
}

function toggleEngine(state) {
	if(parseInt(state) == 1) {
		var val = (0.837/433)*34;
		if(val > 0.835) {
			val = 0.835;
		}
		$('.circle').circleProgress({
			value: val,
			startAngle: 2.08,
			animation: {duration: 1000, easing: "circleProgressEasing"},
			size: 231,
			emptyFill: "rgba(0, 0, 0, 0)",
			thickness: 7,
			fill: {
				gradient: ["rgba(204, 139, 41, 1)", "rgba(204, 139, 41, 1)", "rgba(204, 57, 41, 1)", "rgba(204, 57, 41, 1)"]
			}
		});
		tOut = setTimeout(function() {
			engine = true;
			tOut = false;
		}, 1000);
		$("#engine").addClass("active_engine");
	} else {
		if(tOut) {
			clearTimeout(tOut);
		}
		engine = false;
		$("#engine").removeClass("active_engine");
	}
}

function updateHandbrake(state) {
	if(parseInt(state) == 1) {
		$("#handbrake").addClass("active_handbrake");
	} else {
		$("#handbrake").removeClass("active_handbrake");
	}
}

function updateCheckEngine(state) {
	if(parseInt(state) == 1) {
		$("#check_engine").addClass("active_check_engine");
	} else {
		$("#check_engine").removeClass("active_check_engine");
	}
}

function updateLight(state) {
	if(parseInt(state) == 1) {
		$("#light").addClass("active_light");
	} else {
		$("#light").removeClass("active_light");
	}
}

function updateGear(gear) {
	if(gear != currentGear) {
		if(parseInt(gear) == 0) {
			gear = "R";
		}
		$("#gear").html(gear);
		currentGear = gear;
	}
}

function updateVehicleHealth(hp) {
	vehicleHealth = parseInt(hp);
}

function updateVehicleFuel(fuel, maxFuel) {
	var val = (0.69/parseInt(maxFuel))*parseInt(fuel);
	if(val > 0.69) {
		val = 0.69;
	}
	$('.fuel').circleProgress({
		reverse: true,
		value: val,
		startAngle: 2.75,
		animation: false,
		size: 64,
		emptyFill: "rgba(0, 0, 0, 0)",
		thickness: 4,
		fill: {
		  gradient: ["rgba(255, 153, 51, 1)"]
		}
	});
}

$(document).ready(function() {
	audioElement = document.createElement('audio');
	audioElement.setAttribute('src', 'http://mta/local/files/index.mp3');
	audioElement.volume = 0.05;
});

function toggleVehicle(state) {
	if(parseInt(state) == 1) {
		isInVehicle = true;
	} else {
		isInVehicle = false;
	}
}

function toggleOilCheck(state) {
	if(parseInt(state) == 1) {
		$("#check_oil").addClass("active_check_oil");
	} else {
		$("#check_oil").removeClass("active_check_oil");
	}
}

function updateOdometer(km) {
	$("#odometer").html("<font color='white'>"+km+"</font> <font color='orange'>km</font>");
}

// function updatePosition(x, y) {
	// $("#speedoBg").css({
		// top: y+"px",
		// left: x+"px"
	// })
// }