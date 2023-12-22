var factions = [];
var itemNames = [];
var activePage = -1;
var pageNames = {
	1: "home",
	2: "members",
	3: "vehicles",
	4: "ranks",
	5: "storage",
	6: "duty"
};
var translatePermission = {
	"canSeeHome": "Áttekintés megtekintése.",
	"canSeeMembers": "Tagok megtekintése.",
	"canSeeVehicles": "Járművek megtekintése.",
	"canSeeRanks": "Rangok megtekintése.",
	"canSeeStorage": "Raktár megtekintése.",
	"canSeeDuty": "Dutyk megtekintése.",
	
	"canEditMessage": "Frakció üzenet szerkesztése.",
	"canAddNewItem": "Tárgy hozzáadás a raktárba.",
	"canCreateTicket": "Ticket írás.",
	"canUseEmergencyRadio": "Sürgősségi rádió használata.",
	
	"canSeeMemberDetails": "Tagok adatainak megtekintése.",
	"canSeeVehicleDetails": "Jármű adatainak megtekintése.",
	"canSeeRankDetails": "Rang adatainak megtekintése.",
	"canSeeItemDetails": "Tárgy adatainak megtekintése.",
	"canSeeDutyDetails": "Duty adatainak megtekintése.",
	
	"canAccessMemberActions": "Tag műveletekhez való hozzáférés.",
	"canAccessVehicleActions": "Jármű műveletekhez való hozzáférés.",
	"canAccessRankActions": "Rang műveletekhez való hozzáférés.",
	"canAccessStorageActions": "Raktár műveletekhez való hozzáférés.",
	"canAccessDutyActions": "Duty műveletekhez való hozzáférés.",
	"canAccessDutyMoney": "Frakció pénzhez való hozzáférés. (Kivétel)",
};
var viewerRank = 0;
var viewerLeader = 0;
var selectedFaction = -1;
var userId = 0;
var selectedElement = -1;
var playerList = [];
var rankPanelMode = false;
var noControl = false;
var dutyState = false;
var selectedItems = [];

function showElement(id) {
	var element = $(id);
	if(element) {
		element.css({
			display: "block"
		});
	}
}

function hideElement(id) {
	var element = $(id);
	if(element) {
		element.css({
			display: "none"
		});
	}
}

function receiveItemNames(t) {
	itemNames = t[0];
}

function translateRank(rank) {
	if(selectedFaction > -1) {
		return factions[selectedFaction]["ranks"][rank-1][0] || factions[selectedFaction]["ranks"][rank][0];
	}
	return "Ismeretlen";
}

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function hasPermission(perm) {
	if(viewerLeader == 2) {
		return true;
	}
	if(viewerRank > -1) {
		if(factions[selectedFaction]["permissions"][viewerRank-1].includes(perm)) {
			return true;
		}
	}
	return false;
}

var inviteFoundPlayer = -1;
function searchForPlayer() {
	var t = document.getElementById("usr-text");
	var r = document.getElementById("recommendation");
	r.innerHTML = "<font color='red'>Nincs találat.</font>";
	inviteFoundPlayer = false;
	if(t.value) {
		for(var key in playerList) {
			if(t.value == parseInt(t.value)) {
				if(t.value == playerList[key][1]) {
					inviteFoundPlayer = key;
					r.innerHTML = "Találat: <font color='green'>"+playerList[key][0]+"</font> <font color='orange'>("+playerList[key][1]+")</font>";
				}
			} else {
				if(playerList[key][0].includes(t.value)) {
					inviteFoundPlayer = key;
					r.innerHTML = "Találat: <font color='green'>"+playerList[key][0]+"</font> <font color='orange'>("+playerList[key][1]+")</font>";
				}
			}
		}
	}
}

$(document).ready(function() {
	$("#usr-text").on("input", searchForPlayer);
	$("#rankSalaryEdit").on("input", function() {
		if(this.value != "") {
			if(parseInt(this.value)) {
				if(this.value > 0) {
					if(this.value > 9999) {
						this.value = 9999;
					}
				} else {
					this.value = 0;
				}
			} else {
				this.value = 0;
			}
		}
	});
	$("#listItemCount").on("input", function() {
		if(this.value != "") {
			if(parseInt(this.value)) {
				if(this.value > 0) {
					if(this.value > 400) {
						this.value = 400;
					}
				} else {
					this.value = 1;
				}
			} else {
				this.value = 1;
			}
		}
	});
});

function navigateToPage(id) {
	if(activePage != id) {
		if(pageNames[parseInt(id)]) {
			if(hasPermission("canSee"+capitalizeFirstLetter(pageNames[parseInt(id)])) || viewerLeader > 0) {
				var pageContent = $("#"+pageNames[parseInt(id)])
				if(pageContent) {
					$("#list"+pageNames[parseInt(id)]).addClass("active"+pageNames[parseInt(id)]);
					showElement("#"+pageNames[parseInt(id)]);
					pageContent.animate({
						opacity: 1
					}, 500);
					var currentPage = activePage;
					if(currentPage > -1) {
						var activePageContent = $("#"+pageNames[parseInt(currentPage)])
						$("#list"+pageNames[parseInt(currentPage)]).removeClass("active"+pageNames[parseInt(currentPage)]);
						if(activePageContent) {
							activePageContent.animate({
								opacity: 0
							}, 500);
							setTimeout(function(p) {
								hideElement("#"+pageNames[parseInt(p)]);
							}, 500, currentPage);
						}
					}
					
					activePage = id;
					switch(activePage) {
						case 1: 
							var members = factions[selectedFaction]["members"] || [];
							$("#membercount").html(members.length.toString());
							var membersOnline = factions[selectedFaction]["online"] || [];
							$("#membersonline").html(membersOnline.length.toString());
							$("#rankcount").html(factions[selectedFaction]["ranks"].length.toString());
							var vehicles = factions[selectedFaction]["vehicles"] || [];
							$("#vehiclecount").html(vehicles.length.toString());
							$("#created").html(factions[selectedFaction]["created"]);
							$("#msg").text(factions[selectedFaction]["msg"]);
							$("#money").html(factions[selectedFaction]["money"]);
							if(hasPermission("canEditMessage") || viewerLeader > 0) {	
								showElement("#messageAction");
							} else {
								hideElement("#messageAction");
							}
							if(hasPermission("canAccessDutyMoney") || viewerLeader > 0) {
								showElement("#withdrawAction");
							} else {
								hideElement("#withdrawAction");
							}
							break;
						case 2:
							selectedElement = -1;
							hideElement("#memberDetails");
							if(hasPermission("canAccessMemberActions") || viewerLeader > 0) {
								showElement("#memberActions");
							}  else {
								hideElement("#memberActions");
							}
							var memberlist = $("#memberlist");
							memberlist.empty();
							for(var key in factions[selectedFaction]["members"]) {
								var onlineState = factions[selectedFaction]["online"].includes(factions[selectedFaction]["members"][key][1]) && " - <font color='green'>Online</font>" || " - <font color='red'>Offline</font>";
								memberlist.append("<div id='member"+key+"' name='"+key+"' class='memberElement'>"+factions[selectedFaction]["members"][key][4].replace("_", " ").replace("_", " ")+onlineState+"</div>");
							}
							break;
						case 3:
							selectedElement = -1;
							hideElement("#vehicleDetails");
							hideElement("#vehicleActions");
							var vehiclelist = $("#vehiclelist");
							vehiclelist.empty();
							for(var key in factions[selectedFaction]["vehicles"]) {
								vehiclelist.append("<div id='"+key+"' class='vehicleElement' name='vehicle"+key+"'>"+factions[selectedFaction]["vehicles"][key][0]+" - <font color='grey'>" + factions[selectedFaction]["vehicles"][key][3] + "%</font></div>");
							}
							break;
						case 4:
							selectedElement = -1;
							if(hasPermission("canAccessRankActions") || viewerLeader > 0) {	
								showElement("#rankActions");
							} else {
								hideElement("#rankActions");
							}
							hideElement("#rankDetails");
							var ranklist = $("#ranklist");
							ranklist.empty();
							for(var key in factions[selectedFaction]["ranks"]) {
								ranklist.append("<div id='"+key+"' name='rankElement' class='rankElement'>"+factions[selectedFaction]["ranks"][key][0]+"</div>");
							}
							break;
						case 5:
							selectedElement = -1;
							hideElement("#storageDetails");
							hideElement("#storageActions");
							var itemlist = $("#storageList");
							itemlist.empty();
							if(factions[selectedFaction]["storage"].length > 0) {
								for(var key in factions[selectedFaction]["storage"]) {
									if(factions[selectedFaction]["storage"][key]["quantities"].length > 0) {
										var count = 0;
										for(var key2 in factions[selectedFaction]["storage"][key]["quantities"]) {
											count = count + factions[selectedFaction]["storage"][key]["quantities"][key2][2];
										}
										itemlist.append("<div id='"+key+"' name='storageElement' class='storageElement'>"+itemNames[parseInt(factions[selectedFaction]["storage"][key]["quantities"][0][0])-1][0] + " <font color='grey'>(x"+count+")</font>"+"</div>");
									}
								}
							}
							
							break;
						case 6:
							selectedElement = -1;
							hideElement("#dutyDetails");
							var dutyList = $("#dutyList");
							dutyList.empty();
							for(var key in factions[selectedFaction]["dutys"]) {
								dutyList.append("<div id='"+key+"' name='dutyElement' class='dutyElement'>"+factions[selectedFaction]["dutys"][key]["name"]+"</div>");
							}
							if(hasPermission("canAccessDutyActions")) {
								showElement("#dutyActions");
							} else {
								hideElement("#dutyActions");
							}
							break;
						
					}
				}
			} else {
				mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canSee"+capitalizeFirstLetter(pageNames[parseInt(id)])]);
			}
		} else {
			navigateToPage(1);
		}
	}
}

var selectedList = -1;
var selectedItem = -1;
$(document).click(function(e) {
	var element = e.target;
	if(!noControl) {
		if($(element).attr('name') == "factionElement") {
			if(selectedFaction != parseInt($(element).attr('id'))) {
				$("#"+selectedFaction).removeClass("activefaction");
				$("#"+$(element).attr('id')).addClass("activefaction");
				selectedFaction = parseInt($(element).attr('id'));
				for(var key in factions[selectedFaction]["members"]) {
					var v = factions[selectedFaction]["members"][key];
					if(parseInt(v[1]) == parseInt(userId)) {
						viewerRank = parseInt(v[2]);
						viewerLeader = parseInt(v[3]);
						break;
					}
				};
				$("#"+pageNames[activePage]).css({
					display: "none"
				});
				for(var i in pageNames) {
					if($(".active"+pageNames[i])) {
						$(".active"+pageNames[i]).removeClass("active"+pageNames[i]);
					}
				}
				activePage = -1;
				navigateToPage(1);
			}
		}
		switch(activePage) {
			case 1:
			
				break;
			case 2: 
				if($(element).hasClass("memberElement")) {
					if(hasPermission("canSeeMemberDetails") || viewerLeader > 0) {
						if($(".activeMember")) {
							$(".activeMember").removeClass("activeMember");
							hideElement("#memberDetails");
							selectedElement = -1;
						}
						selectedElement = parseInt($(element).attr('name'));
						$(element).addClass("activeMember");
						showElement("#memberDetails");
						
						$("#detailRank").html("<font color='#0081c7'>"+translateRank(factions[selectedFaction]["members"][selectedElement][2])+"</font>");
						$("#detailIsLeader").html((factions[selectedFaction]["members"][selectedElement][3] == 0 && "<font color='red'>Nem" || factions[selectedFaction]["members"][selectedElement][3] == 1 && "<font color='green'>Igen" || factions[selectedFaction]["members"][selectedElement][3] == 2 && "<font color='green'>Igen</font> <font color='orange'>(Fő leader)") +"</font>");
						$("#detailSalary").html("$"+factions[selectedFaction]["ranks"][factions[selectedFaction]["members"][selectedElement][2]-1][1]);
						$("#detailJoined").html("<font color='#0081c7'>" + (factions[selectedFaction]["members"][selectedElement][5] == false && "Most" || factions[selectedFaction]["members"][selectedElement][5]) + "</font>");
						$("#detailLastPlace").html("Ismeretlen");
					} else {
						mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canSeeMemberDetails"]);
					}
				} else if(selectedElement > -1) {
					if($(".activeMember") && $(element).parent().attr('id') != "memberActions") {
						$(".activeMember").removeClass("activeMember");
						hideElement("#memberDetails");
					}
					selectedElement = -1;
				}
				break;
			case 3: 
				if($(element).hasClass("vehicleElement")) {
					if(hasPermission("canSeeVehicleDetails")) {
						if($(".activeVehicle")) {
							$(".activeVehicle").removeClass("activeVehicle");
							hideElement("#vehicleDetails");
							hideElement("#vehicleActions");
							selectedElement = -1;
						}
						showElement("#vehicleDetails");
						$(element).addClass("activeVehicle");
						selectedElement = parseInt($(element).attr("id"));
						$("#vehicleID").html(factions[selectedFaction]["vehicles"][selectedElement][2]);
						$("#vehicleLocation").html(factions[selectedFaction]["vehicles"][selectedElement][1]);
						if(hasPermission("canAccessVehicleActions")) {
							showElement("#vehicleActions");
						} else {
							mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canAccessVehicleActions"]);
						}
					} else {
						mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canSeeVehicleDetails"]);
					}
				} else if(selectedElement > -1) {
					if($(".activeVehicle") && $(element).parent().attr('id') != "vehicleActions") {
						$(".activeVehicle").removeClass("activeVehicle");
						hideElement("#vehicleDetails");
						hideElement("#vehicleActions");
						selectedElement = -1;
					}
				}
				break;
			case 4:
				if($(element).hasClass("rankElement")) {
					if(hasPermission("canSeeRankDetails")) {
						if($(".activeRank")) {
							$(".activeRank").removeClass("activeRank");
							hideElement("#rankDetails");
							selectedElement = -1;
						}
						showElement("#rankDetails");
						$(element).addClass("activeRank");
						selectedElement = parseInt($(element).attr("id"));
						$("#rankName").html("<font color='orange'>" + factions[selectedFaction]["ranks"][selectedElement][0] + "</font>");
						$("#rankSalary").html("Fizetés: <font color='orange'>$</font>" + factions[selectedFaction]["ranks"][selectedElement][1]);
					} else {
						mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canSeeRankDetails"]);
					}
				} else if(selectedElement > -1) {
					if($(".activeRank") && $(element).parent().attr('id') != "rankActionlist") {
						if(!noControl) {
							$(".activeRank").removeClass("activeRank");
							hideElement("#rankDetails");
							selectedElement = -1;
						}
					}
				}
				break;
			case 5:
				if($(element).hasClass("storageElement")) {
					if(hasPermission("canSeeItemDetails")) {
						if($(".activeItem")) {
							$(".activeItem").removeClass("activeItem");
							hideElement("#vehicleDetails");
							hideElement("#vehicleActions");
							selectedElement = -1;
						}
						showElement("#storageDetails");
						$(element).addClass("activeItem");
						selectedElement = parseInt($(element).attr("id"));
						var count = 0;
						for(var key in factions[selectedFaction]["storage"][selectedElement]["quantities"]) {
							count = count + factions[selectedFaction]["storage"][selectedElement]["quantities"][key][2];
						}
						$("#itemCountDetail").html(count);
						if(hasPermission("canAccessStorageActions")) {
							showElement("#storageActions");
						} else {
							mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canAccessStorageActions"]);
						}
					} else {
						mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canSeeItemDetails"]);
					}
				} else if(selectedElement > -1) {
					if($(".activeItem") && $(element).parent().attr('id') != "storageActions") {
						$(".activeItem").removeClass("activeItem");
						hideElement("#storageDetails");
						hideElement("#storageActions");
						selectedElement = -1;
					}
				}
				break;
			case 6:
				if($(element).hasClass("dutyElement")) {
					if(hasPermission("canSeeDutyDetails")) {
						if($(".activeDutyElement")) {
							$(".activeDutyElement").removeClass("activeDutyElement");
							hideElement("#dutyDetails");
							selectedElement = -1;
						}
						showElement("#dutyDetails");
						$(element).addClass("activeDutyElement");
						selectedElement = parseInt($(element).attr("id"));
						$("#dutyName").html(factions[selectedFaction]["dutys"][selectedElement]["name"]);
						var date = new Date(factions[selectedFaction]["dutys"][selectedElement]["created"]*1000);
						var year = date.getFullYear();
						var month = "0" + (parseInt(date.getMonth())+1);
						var day = "0" + (parseInt(date.getDay())+21);
						var hours = date.getHours();
						var minutes = "0" + date.getMinutes();
						var seconds = "0" + date.getSeconds();
						var formattedTime = year+'.'+month.substr(-2)+'.'+day.substr(-2)+'. ' + hours + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);
						$("#dutyDate").html(" <font color='orange'>"+formattedTime+"</font>");
						$("#dutyRank").html(translateRank(parseInt(factions[selectedFaction]["dutys"][selectedElement]["rank"])));
					} else {
						mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canSeeDutyDetails"]);
					}
				} else if(selectedElement > -1) {
					if($(".activeDutyElement") && $(element).parent().attr('id') != "dutyActions") {
						$(".activeDutyElement").removeClass("activeDutyElement");
						hideElement("#dutyDetails");
						selectedElement = -1;
					}
				}
				break;
		}
	} else {
		if(dutyState) {
			if($(element).attr("name") == "itemList") {
				if($(".activeItem")) {
					$(".activeItem").removeClass("activeItem");
					selectedList = -1;
					selectedItem = -1;
					hideElement("#addButton");
					hideElement("#removeButton");
					hideElement("#listItemCount");
				}
				$(element).addClass("activeItem");
				selectedList = $(element).attr('id');
				showElement("#addButton");
				showElement("#listItemCount");
				$("#listItemCount").val("1");
			} else if($(element).attr("name") == "selectedItem") {
				if($(".activeItem")) {
					$(".activeItem").removeClass("activeItem");
					selectedItem = -1;
					selectedList = -1;
					hideElement("#addButton");
					hideElement("#removeButton");
					hideElement("#listItemCount");
				}
				$(element).addClass("activeItem");
				selectedItem = parseInt($(element).attr("id"));
				showElement("#removeButton");
			} else {
				if(selectedList > -1){
					if($(".activeItem") && $(element).parent().attr('id') != "addButton" && $(element).attr('id') != "listItemCount") {
						$(".activeItem").removeClass("activeItem");
						selectedList = -1;
						hideElement("#addButton");
						hideElement("#removeButton");
						hideElement("#listItemCount");
					}
				} else if(selectedItem > -1) {
					if($(".activeItem") && $(element).parent().attr('id') != "removeButton") {
						$(".activeItem").removeClass("activeItem");
						selectedList = -1;
						hideElement("#addButton");
						hideElement("#removeButton");
						hideElement("#listItemCount");
					}
				}
			}
		}
	}
});

function loadFactionData(id, data) {
	data = data[0];
	factions[parseInt(id)] = data;
	
	if(selectedFaction == -1) {
		$("#factionlist").append("<div class='factionElement activefaction' name='factionElement' id='"+id+"'>"+data['name']+"</div>");
		selectedFaction = parseInt(id);
	} else {
		$("#factionlist").append("<div class='factionElement' name='factionElement' id='"+id+"'>"+data['name']+"</div>");
	}
}

function loadFactionMembers(id, data, data2, dbid) {
	data = data[0];
	data2 = data2[0];
	
	userId = dbid;
	
	factions[id]["members"] = data;
	factions[id]["online"] = data2;
	
	if(selectedFaction == id || selectedFaction == -1) {
		for(var key in data) {
			var v = data[key];
			if(parseInt(v[1]) == parseInt(dbid)) {
				viewerRank = parseInt(v[2]);
				viewerLeader = parseInt(v[3]);
				break;
			}
		};
	}
	navigateToPage(1);
}

function loadFactionVehicles(id, data) {
	data = data[0];
	factions[id]["vehicles"] = data;
}

function receivePlayers(t) {
	playerList = t[0];
}

function refreshFactionData(id, data) {
	factions[parseInt(id)] = data[0];
	var page = activePage;
	activePage = -1
	hideElement("#"+pageNames[page]);
	navigateToPage(page);
}

function refreshFactionMembers(id, data, data2, dbid) {
	data = data[0];
	data2 = data2[0];
	factions[parseInt(id)]["members"] = data;
	factions[parseInt(id)]["online"] = data2;
	var page = activePage;
	activePage = -1
	hideElement("#"+pageNames[page]);
	navigateToPage(page);
	userId = parseInt(dbid);
	if(selectedFaction == id || selectedFaction == -1) {
		for(var key in data) {
			var v = data[key];
			if(parseInt(v[1]) == parseInt(dbid)) {
				viewerRank = parseInt(v[2]);
				viewerLeader = parseInt(v[3]);
				break;
			}
		};
	}
}

function refreshFactionVehicles(id, data) {
	factions[parseInt(id)]["vehicles"] = data[0];
	
	var page = activePage;
	activePage = -1
	hideElement("#"+pageNames[page]);
	navigateToPage(page);
}

var spam = false;
function showInvite() {
	if(!spam) {
		noControl = true;
		$("#bg").addClass("inviteBackground");
		$("#invitePanel").css({
			display: "block"
		});
		mta.triggerEvent("getPlayers");
		$("#usr-text").val("");
		$("recommendation").html("");
		spam = true;
		setTimeout(function() { spam = false; }, 2000);
	} else {
		mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
	}
}

function confirmInvitePanel() {
	if(!spam) {
		if(inviteFoundPlayer) {
			mta.triggerEvent("addToFaction", playerList[inviteFoundPlayer][1], selectedFaction);
		} else {
			mta.triggerEvent("showBox", "error", "Nincs talált játékos.");
		}
		spam = true;
		setTimeout(function() { spam = false; }, 2000);
	} else {
		mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
	}
}

function closeInvitePanel() {
	noControl = false;
	$("#bg").removeClass("inviteBackground");
	$("#invitePanel").css({
		display: "none"
	});
	$("#usr-text").val("");
	$("recommendation").html("");
}

function promote() {
	if(selectedElement > -1) {
		if(!spam) {
			mta.triggerEvent("promoteMember", selectedFaction, selectedElement+1);
			spam = true;
			setTimeout(function() { spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	} else {
		mta.triggerEvent("showBox", "info", "Előbb válassz ki egy tagot!");
	}
}


function demote() {
	if(selectedElement > -1) {
		if(!spam) {
			mta.triggerEvent("demoteMember", selectedFaction, selectedElement+1);
			spam = true;
			setTimeout(function() { spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	} else {
		mta.triggerEvent("showBox", "info", "Előbb válassz ki egy tagot!");
	}
}

function toggleLeader() {
	if(selectedElement > -1) {
		if(!spam) {
			mta.triggerEvent("toggleLeader", selectedFaction, selectedElement+1);
			spam = true;
			setTimeout(function() { spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	} else {
		mta.triggerEvent("showBox", "info", "Előbb válassz ki egy tagot!");
	}
}

function kick() {
	if(selectedElement > -1) {
		if(!spam) {
			mta.triggerEvent("kickMember", selectedFaction, selectedElement+1);
			spam = true;
			setTimeout(function() { spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	} else {
		mta.triggerEvent("showBox", "info", "Előbb válassz ki egy tagot!");
	}
}

function getKey() {
	if(selectedElement > -1) {
		if(!spam) {
			mta.triggerEvent("getKey", factions[selectedFaction]["vehicles"][selectedElement][2]);
			spam = true;
			setTimeout(function() { spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	} else {
		mta.triggerEvent("showBox", "info", "Előbb válassz ki egy tagot!");
	}
}

function createRank() {
	if(!noControl) {
		if(!spam) {
			showElement("#rankPanel");
			$("#bg").addClass("inviteBackground");
			rankPanelMode = 1;
			noControl = true;
			$("#permissionContent").empty();
			for(var key in translatePermission) {
				$("#permissionContent").append('<label class="container">'+translatePermission[key]+'<input type="checkbox" value="'+key+'"><span class="checkmark"></span></label>');
			}
			spam = true;
			setTimeout(function() { spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
	
}

function arraysEqual(arr1, arr2) {
    if(arr1.length !== arr2.length)
        return false;
    for(var i = arr1.length; i--;) {
        if(arr1[i] !== arr2[i])
            return false;
    }

    return true;
}

function saveRank() {
	if(!spam) {
		var rankName = $("#rankNameEdit").val();
		var rankSalary = $("#rankSalaryEdit").val();
		if(rankName != "" && rankSalary != "") {
			var perms = [];
			$("#permissionContent").children('label').children('input').each(function(i, v) {
				if($(v).is(':checked')) {
					perms.push($(v).val());
				}
			});
			if(rankPanelMode == 1) {
				mta.triggerEvent("createRank", selectedFaction, rankName, rankSalary, JSON.stringify(perms));
			} else {
				var existingPerms = factions[selectedFaction]["permissions"][selectedElement] || [];
				if(rankName != factions[selectedFaction]["ranks"][selectedElement][0] || rankSalary != factions[selectedFaction]["ranks"][selectedElement][1] || !arraysEqual(perms, existingPerms)) {
					mta.triggerEvent("editRank", selectedFaction, selectedElement+1, rankName, rankSalary, JSON.stringify(perms));
				} else {
					mta.triggerEvent("showBox", "error", "Nem történt adatváltoztatás!");
				}
			}
		} else {
			mta.triggerEvent("showBox", "error", "Nem adtál meg valós értéket!");
		}
	} else {
		mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
	}
}

function editRank() {
	if(!spam) {
		if(selectedElement > -1) {
			showElement("#rankPanel");
			$("#bg").addClass("inviteBackground");
			rankPanelMode = 2;
			noControl = true;
			$("#rankNameEdit").val(factions[selectedFaction]["ranks"][selectedElement][0]);
			$("#rankSalaryEdit").val(factions[selectedFaction]["ranks"][selectedElement][1]);
			$("#permissionContent").empty();
			rankPermissions = factions[selectedFaction]["permissions"][selectedElement] || [];
			for(var key in translatePermission) {
				if(rankPermissions.includes(key)) {
					$("#permissionContent").append('<label class="container">'+translatePermission[key]+'<input type="checkbox" checked="checked" value="'+key+'"><span class="checkmark"></span></label>');
				} else {
					$("#permissionContent").append('<label class="container">'+translatePermission[key]+'<input type="checkbox" value="'+key+'"><span class="checkmark"></span></label>');
				}
			}
		} else {
			mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy rangot!");
		}
	} else {
		mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
	}
}

function closeRankPanel() {
	// if(!spam) {
		$("#rankNameEdit").val("");
		$("#rankSalaryEdit").val("");
		hideElement("#rankPanel");
		$("#bg").removeClass("inviteBackground");
		noControl = false;
		rankPanelMode = false;
		spam = true;
		setTimeout(function() { spam = false; }, 2000);
	// } else {
		// mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
	// }
}

function deleteRank() {
	if(!spam) {
		if(selectedElement > -1) {
			mta.triggerEvent("deleteRank", selectedFaction, selectedElement+1);
		} else {
			mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy rangot!");
		}
	} else {
		mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
	}
}

function deleteStorageItem() {
	if(!noControl) {
		if(!spam) {
			if(selectedElement > -1) {
				mta.triggerEvent("deleteStorageItem", selectedFaction, factions[selectedFaction]["storage"][selectedElement]["quantities"][0][0]);
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy tárgyat!");
			}
			spam = true;
			setTimeout(function() { spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function createDuty() {
	if(!noControl) {
		if(!spam) {
			dutyState = 1;
			showElement("#dutyPanel");
			noControl = true;
			$("#bg").addClass("inviteBackground");
			
			$("#dutyNameEdit").val("");
			$("#selectedItems").empty();
			$("#itemList").empty();
			
			selectedItems = [];
			
			var storageList = $("#itemList");
			storageList.empty();
			
			for(var key in factions[selectedFaction]["storage"]) {
				if(factions[selectedFaction]["storage"][key]["quantities"].length > 0) {
					var count = 0;
					for(var key2 in factions[selectedFaction]["storage"][key]["quantities"]) {
						count = count + factions[selectedFaction]["storage"][key]["quantities"][key2][2];
					}
					storageList.append("<div id='"+key+"' style='width: 198px;' name='itemList' class='storageElement'>"+itemNames[parseInt(factions[selectedFaction]["storage"][key]["quantities"][0][0])][0]+"<font color='grey'>(x"+count+")</font></div>");
				}
				count = 0;
			}
			
			var x = document.getElementById("dutyRanks");
			while(x.firstChild) {
				x.removeChild(x.firstChild);
			}
			
			for(var k in factions[selectedFaction]["ranks"]) {
				var option = document.createElement("option");
				option.value = k;
				option.classList.add("rankSelectOption");
				option.text = factions[selectedFaction]["ranks"][k][0];
				x.add(option);
			}
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function editDuty() {
	if(!noControl) {
		if(!spam) {
			if(selectedElement > -1) {
				
				dutyState = 2;
				showElement("#dutyPanel");
				noControl = true;
				$("#bg").addClass("inviteBackground");
				
				$("#dutyNameEdit").val(factions[selectedFaction]["dutys"][selectedElement]["name"]);
				$("#selectedItems").empty();
				$("#itemList").empty();
				
				selectedItems = [];
				
				var storageList = $("#itemList");
				storageList.empty();
				for(var key in factions[selectedFaction]["storage"]) {
					if(factions[selectedFaction]["storage"][key]["quantities"].length > 0) {
						var count = 0;
						for(var key2 in factions[selectedFaction]["storage"][key]["quantities"]) {
							count = count + factions[selectedFaction]["storage"][key]["quantities"][key2][2];
						}
						storageList.append("<div id='"+key+"' style='width: 198px;' name='itemList' class='storageElement'>"+itemNames[parseInt(factions[selectedFaction]["storage"][key]["quantities"][0][0])][0]+"<font color='grey'>(x"+count+")</font></div>");
					}
					count = 0;
				}
				
				for(var key in factions[selectedFaction]["dutys"][selectedElement]["items"]) {
					var item = factions[selectedFaction]["dutys"][selectedElement]["items"][key]["itemDetails"][0]
					var count = factions[selectedFaction]["dutys"][selectedElement]["items"][key]["quantity"];
					selectedItems.push([item, count]);
				}
				
				var x = document.getElementById("dutyRanks");
				while(x.firstChild) {
					x.removeChild(x.firstChild);
				}
				
				for(var k in factions[selectedFaction]["ranks"]) {
					var option = document.createElement("option");
					option.value = k;
					option.classList.add("rankSelectOption");
					option.text = factions[selectedFaction]["ranks"][k][0];
					x.add(option);
				}
				
				x.selectedIndex = factions[selectedFaction]["dutys"][selectedElement]["rank"]-1;
				
				var sItems = $("#selectedItems");
				sItems.empty();
				for(var index in selectedItems) {
					if(selectedItems[index] != null) {
						var count2 = selectedItems[index][1];
						sItems.append("<div id='"+index+"' name='selectedItem' style='width: 198px;' class='storageElement'>"+itemNames[parseInt(selectedItems[index][0])][0]+"<font color='grey'>(x"+count2+")</font>"+"</div>");
						count2 = 0;
					}
				}
				
				selectedList = -1;
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy tárgyat!");
			}
			spam = true;
			setTimeout(function() { spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function deleteDuty() {
	if(!noControl) {
		if(!spam) {
			if(selectedElement > -1) {
				mta.triggerEvent("deleteDuty", selectedFaction, selectedElement+1);
				spam = true;
				setTimeout(function() { spam = false; }, 2000);
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy duty-t!");
			}
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function closeDutyPanel() {
	// if(!spam) {
		$("#bg").removeClass("inviteBackground");
		hideElement("#dutyPanel");
		noControl = false;
		dutyState = false;
		// spam = true;
		// setTimeout(function() { spam = false; }, 2000);
	// } else {
		// mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!"); 
	// }
}

function addItemToSelected() {
	var storageList = $("#selectedItems");
	storageList.empty();
	var count = parseInt($("#listItemCount").val());
	if(count && count > 0) {
		for(var i in factions[selectedFaction]["storage"]) {
			if(i == selectedList) {	
				var found = false;
				for(var key in selectedItems) {
					if(selectedItems[key] != null) {
						if(factions[selectedFaction]["storage"][i]["quantities"][0][0] == selectedItems[key][0]) {
							if(count < 400) {
								selectedItems[key][1] = selectedItems[key][1]+count;
								found = true;
							}
							
						}
					}
				}
				if(!found) {
					selectedItems.push([factions[selectedFaction]["storage"][i]["quantities"][0][0], count]);
				}
				break;
			}
		}
		for(var index in selectedItems) {
			if(selectedItems[index] != null) {
				var count2 = selectedItems[index][1];
				storageList.append("<div id='"+index+"' class='storageElement' style='width: 198px;' name='selectedItem'>"+itemNames[parseInt(selectedItems[index][0])][0] + " <font color='grey'>(x"+count2+")</font>"+"</div>");
			}
		}
		$("#activeItem").removeClass("activeItem");
		hideElement("#addButton");
		hideElement("#listItemCount");
		selectedList = -1
	} else {
		mta.triggerEvent("showBox", "error", "Darabszámnak valós értéket adj meg!");
	}
}

function removeFromSelected() {
	var storageList = $("#selectedItems");
	storageList.empty();
	if(selectedItems[selectedItem] != null) {
		selectedItems[selectedItem] = null;
	}
	for(var key in selectedItems) {
		if(selectedItems[key] != null) {
			var count = selectedItems[key][1];
			storageList.append("<div id='"+key+"' class='storageElement' style='width: 198px;' name='selectedItem'>"+itemNames[parseInt(selectedItems[key][0])][0] + " <font color='grey'>(x"+count+")</font>"+"</div>");
			count = 0;
		}
		
	}
	if($(".activeItem")) {
		$(".activeItem").removeClass("activeItem");
	}
	hideElement("#removeButton");
	selectedItem = -1;
}

function saveDuty() {
	if(!spam) {
		var dutyName = $("#dutyNameEdit").val();
		var dutyRank = $("#dutyRanks").val();
		if(dutyName != "" && dutyRank != "") {
			if(dutyState == 1) {
				mta.triggerEvent("createDuty", selectedFaction, dutyName, dutyRank, JSON.stringify(selectedItems));
			} else {
				if(factions[selectedFaction]["dutys"][selectedElement] != dutyName || factions[selectedFaction]["dutys"][selectedElement]["rank"] != parseInt(dutyRank) || !arraysEqual(factions[selectedFaction]["dutys"][selectedElement]["items"], selectedItems)) {
					spam = true;
					setTimeout(function() { spam = false; }, 2000);
					mta.triggerEvent("editDuty", selectedFaction, selectedElement+1, dutyName, dutyRank, JSON.stringify(selectedItems));
				} else {
					mta.triggerEvent("showBox", "error", "Nem történt adatváltoztatás"); 
				}
			}
		} else {
			mta.triggerEvent("showBox", "error", "Valós értékeket adj meg!"); 
		}
	} else {
		mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!"); 
	}
}

function changeMSG() {
	noControl = true;
	showElement("#messagePanel");
	$("#bg").addClass("inviteBackground");
}



function saveMessage() {
	if(!spam) {
		var msg = $("#factionMessage").val();
		if(msg.length > 0) {
			// if(isHTML(msg)) {
				mta.triggerEvent("saveMessage", selectedFaction, msg);
				spam = true;
				setTimeout(function() { spam = false; }, 2000);
			// } else {
				// mta.triggerEvent("showBox", "error", "Az üzeneted HTML tagokat tartalmaz, ezért érvénytelen!"); 
			// }
		} else {
			mta.triggerEvent("showBox", "error", "Nem adtál meg üzenetet!"); 
		}
	} else {
		mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!"); 
	}
}

function closeMessage() {
	noControl = false;
	hideElement("#messagePanel");
	$("#bg").removeClass("inviteBackground");
}

function deposit() {
	noControl = true;
	showElement("#depositPanel");
	$("#bg").addClass("inviteBackground");
}

function closeDepositPanel() {
	noControl = false;
	hideElement("#depositPanel");
	$("#bg").removeClass("inviteBackground");
}

function depositMoney() {
	if(!spam) {
		var money = parseInt($("#depAmount").val());
		if(money && money > 0)  {
			mta.triggerEvent("changeMoney", selectedFaction, 2, money);
			spam = true;
			setTimeout(function() { spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "error", "Nem adtál meg érvényes értéket!"); 
		}
	} else {
		mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!"); 
	}
}

function withdraw() {
	noControl = true;
	showElement("#withdrawPanel");
	$("#bg").addClass("inviteBackground");
}

function closeWithdrawPanel() {
	noControl = false;
	hideElement("#withdrawPanel");
	$("#bg").removeClass("inviteBackground");
}

function withdrawMoney() {
	if(!spam) {
		var money = parseInt($("#witAmount").val());
		if(money && money > 0)  {
			mta.triggerEvent("changeMoney", selectedFaction, 1, money);
			spam = true;
			setTimeout(function() { spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "error", "Nem adtál meg érvényes értéket!"); 
		}
	} else {
		mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!"); 
	}
}