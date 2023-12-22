values = [];
values["hp"] = 0;
values["armor"] = 0;
values["hunger"] = 0;
values["thirsty"] = 0;
values["stamina"] = 0;

colors = [];
colors["hp"] = "rgb(210, 77, 87)";
colors["armor"] = "rgb(74, 158, 222)";
colors["hunger"] = "rgb(182, 167, 64)";
colors["thirsty"] = "rgb(102, 204, 255)";
colors["stamina"] = "rgb(220, 220, 220)";

$(document).ready(function() {
	change("hp", 0);
	change("armor", 0); 
	change("hunger", 0);
	change("thirsty", 0);
	change("stamina", 0);

    mta.triggerEvent("js->Request");
});

function change(type, percent) {
    $("#" + type).hexagonProgress({
        value: percent / 100,
        startAngle: Math.PI / 2,
        animation: true,
        animationStartValue: values[type] / 100,
        lineCap: "square",
        background: {color: "rgba(0, 0, 0, .65)"},
        clip: true,
        lineWidth: 5,
        lineBackFill: {color: "rgba(0, 0, 0, .8)"},
        lineFrontFill: {color: colors[type]},
    });

    values[type] = percent;
}