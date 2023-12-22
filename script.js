var activePage = false;
var translatePages = {
	1: "home",
	2: "members",
	3: "vehicles",
	4: "ranks",
	5: "storage",
	6: "duty",
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
	"canAccessMoney": "Frakció pénzhez való hozzáférés.",
};
var factions = [];
var faction_members = [];
var faction_members_online = [];
var faction_vehicles = [];
var itemNames = [];
var timer = null;
var selectedFaction = 0;
var selectedElement = -1;
var noControl = false;
var playerList = [];
var inviteFoundPlayer = false;
var leaderType = 0;
var viewerRank = -1;
var spam = false;
var viewerID = 0;
var rankPermissions = [];

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function hasPermission(perm, showMessage) {
	if(leaderType == 2) {
		return true;
	}
	if(viewerRank > -1) {
		if(factions[selectedFaction]["permissions"][viewerRank].includes(perm)) {
			return true;
		}
		if(showMessage) {
			mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission[perm]);
		}
	}
	return false;
}

function loadPageContent(pageID) {
	var hasPerm = hasPermission("canSee"+capitalizeFirstLetter(activePage), false) || leaderType > 0;
	if(hasPerm) {
		var element = document.getElementById(pageID);
		var op = 0.1;
		element.style.opacity = op;
		element.style.display = 'block';
		var timer2 = setInterval(function () {
			if (op >= 1){
				clearInterval(timer2);
				timer = null;
				contentById(element.id);
			}
			element.style.opacity = op;
			element.style.filter = 'alpha(opacity=' + op * 100 + ")";
			op += op * 0.1;
		}, 2);
	}
}

function loadPageContentByElement(element) {
	var hasPerm = hasPermission("canSee"+capitalizeFirstLetter(activePage), false) || leaderType > 0;
	if(hasPerm) {
		var op = 0.1;
		element.style.opacity = op;
		element.style.display = 'block';
		var timer2 = setInterval(function () {
			if (op >= 1){
				clearInterval(timer2);
				timer = null;
				contentById(element.id);
			}
			element.style.opacity = op;
			element.style.filter = 'alpha(opacity=' + op * 100 + ")";
			op += op * 0.1;
		}, 2);
	}
}

function translateRank(rank) {
	if(selectedFaction > 0) {
		return factions[selectedFaction]["ranks"][rank-1][0] || factions[selectedFaction]["ranks"][rank][0];
	}
	return "Ismeretlen";
}

function contentById(id) {
	switch(id) {
		case "home":
			var memberCount = document.getElementById("membercount");
			var membersOnline = document.getElementById("membersonline");
			var rankCount = document.getElementById("rankcount");
			var vehicleCount = document.getElementById("vehiclecount");
			var Created = document.getElementById("created");
			var Msg = document.getElementById("msg");
			var Money = document.getElementById("money");
			memberCount.innerHTML = faction_members[selectedFaction].length || 0;
			membersOnline.innerHTML = faction_members_online[selectedFaction].length || 0;
			rankCount.innerHTML = factions[selectedFaction]["ranks"].length;
			vehicleCount.innerHTML = 1;
			Created.innerHTML = factions[selectedFaction]["created"];
			Msg.innerHTML = factions[selectedFaction]["msg"];
			Money.innerHTML = factions[selectedFaction]["money"];
			var perm = hasPermission("canEditMessage", false);
			if(!perm && leaderType == 0) {
				mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canEditMessage"]);
			}
			memberActions.style.display = perm && "block" || "none" || leaderType > 0 && "block" || "none";
			break;
		case "members":
			selectedElement = -1;
			var memberDetails = document.getElementById("memberDetails");
			var memberActions = document.getElementById("memberActions");
			var perm = hasPermission("canAccessMemberActions", false);
			if(!perm && leaderType == 0) {
				mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canAccessMemberActions"]);
			}
			memberActions.style.display = perm && "block" || "none" || leaderType > 0 && "block" || "none";
			memberDetails.style.display = "none";
			var memberlist = document.getElementById("memberlist");
			while(memberlist.firstChild) {
				memberlist.removeChild(memberlist.firstChild);
			}
			for(var key in faction_members[selectedFaction]) {
				var newElement = document.createElement('div');
				newElement.id = "member"+key;
				newElement.name = key;
				newElement.classList.add("memberElement");
				var onlineState = (faction_members[selectedFaction][key][5] == false && true || faction_members[selectedFaction][key][5] == "false" && true || false) && " - <font color='green'>Online</font>" || " - <font color='red'>Offline</font>";
				newElement.innerHTML = faction_members[selectedFaction][key][4].replace("_", " ") + onlineState;
				memberlist.appendChild(newElement);
			}
			break;
		case "vehicles":
			selectedElement = -1;
			var vehicleDetails = document.getElementById("vehicleDetails");
			var vehicleActions = document.getElementById("vehicleActions");
			var vehiclelist = document.getElementById("vehiclelist");
			while(vehiclelist.firstChild) {
				vehiclelist.removeChild(vehiclelist.firstChild);
			}
			for(var key in faction_vehicles[selectedFaction]) {
				var newElement = document.createElement('div');
				newElement.id = "vehicle"+key;
				newElement.name = key;
				newElement.classList.add("vehicleElement");
				newElement.innerHTML = faction_vehicles[selectedFaction][key][0] + " - <font color='grey'>" + faction_vehicles[selectedFaction][key][3] + "%</font>";
				vehiclelist.appendChild(newElement);
			}
			break;
		case "ranks":
			selectedElement = -1;
			var rankDetails = document.getElementById("rankDetails");
			var rankActions = document.getElementById("rankActions");
			var perm = hasPermission("canAccessRankActions", true);
			rankActions.style.display = perm && "block" || "none";
			
			rankDetails.style.display = "none";
			
			var ranklist = document.getElementById("ranklist");
			while(ranklist.firstChild) {
				ranklist.removeChild(ranklist.firstChild);
			}
			for(var key in factions[selectedFaction]["ranks"]) {
				var newElement = document.createElement('div');
				newElement.id = "rank"+key;
				newElement.name = key;
				newElement.classList.add("rankElement");
				newElement.innerHTML = factions[selectedFaction]["ranks"][key][0];
				ranklist.appendChild(newElement);
			}
			break;
		case "storage":
			selectedElement = -1;
			var storageDetails = document.getElementById("storageDetails");
			var storageActions = document.getElementById("storageActions");
			
			storageActions.style.display = "none";
			storageDetails.style.display = "none";
			
			var storageList = document.getElementById("storageList");
			while(storageList.firstChild) {
				storageList.removeChild(storageList.firstChild);
			}
			
			for(var key in factions[selectedFaction]["storage"]) {
				if(factions[selectedFaction]["storage"][key]["quantities"].length > 0) {
					var newElement = document.createElement('div');
					newElement.id = "storage"+key;
					newElement.name = key;
					newElement.classList.add("storageElement");
					newElement.innerHTML = itemNames[parseInt(factions[selectedFaction]["storage"][key]["quantities"][0])-1][0];
					storageList.appendChild(newElement);
				}
			}
			break;
		case "duty":
			selectedElement = -1;
			var dutyDetails = document.getElementById("dutyDetails");
			var dutyActions = document.getElementById("dutyActions");
			
			dutyDetails.style.display = "none";

			var perm = hasPermission("canAccessDutyActions", true);
			dutyActions.style.display = perm && "block" || "none";
			
			var dutyList = document.getElementById("dutyList");
			while(dutyList.firstChild) {
				dutyList.removeChild(dutyList.firstChild);
			}
			
			for(var key in factions[selectedFaction]["dutys"]) {
				var newElement = document.createElement('div');
				newElement.id = "duty"+key;
				newElement.name = key;
				newElement.classList.add("dutyElement");
				newElement.innerHTML = factions[selectedFaction]["dutys"][key]["name"];
				dutyList.appendChild(newElement);
			}
			break;
	}
}

function navigateToPage(id) {
	var pageID = translatePages[id];
	if(!noControl) {
		var hasPerm = hasPermission("canSee"+capitalizeFirstLetter(pageID), false) || leaderType > 0;
		if(hasPerm) {
			if(activePage != false) {
				if(translatePages[id] != activePage) {
					if(timer) {
						return;
					}
					var activeElement = document.getElementById(activePage);
					var op = 1;
					document.getElementById("list"+activePage).classList.remove("active"+activePage);
					document.getElementById("list"+pageID).classList.add("active"+pageID);
					timer = setInterval(function () {
						if (op <= 0.1){
							clearInterval(timer);
							activeElement.style.display = 'none';
							activePage = pageID;
							loadPageContent(pageID);
						}
						activeElement.style.opacity = op;
						activeElement.style.filter = 'alpha(opacity=' + op * 100 + ")";
						op -= op * 0.1;
					}, 2);
				}
			} else {
				if(hasPermission("canSee"+capitalizeFirstLetter(pageID), false) || leaderType > 0) {
					activePage = pageID;
					document.getElementById("list"+pageID).classList.add("active"+pageID);
					loadPageContentByElement(document.getElementById(pageID));
				}
				// console.log("Anyád");
			}
		} else {
			mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canSee"+capitalizeFirstLetter(pageID)]);
		}
	}
}

var selectedItem = -1;
var selectedList = -1;
var activeDutyPanel = false;
var dutyState = false;
var selectedItems = [];
document.addEventListener('click', function(e) {
	var element = e.target;
	if(!noControl) {
		var fc = document.getElementById("factionlist").childNodes;
		if(fc.length > 0) {
			for(var i = 0; i < fc.length; i++) {
				if(fc[i].id == element.id) {
					if(selectedFaction != element.name) {
						var active = document.getElementById("faction"+selectedFaction);
						if(activePage) {
							var activeElement = document.getElementById(activePage);
							activeElement.style.display = "none";
							var navbar = document.getElementById("list"+activePage);
							navbar.classList.remove("active"+activePage)
							activeElement.style.display = "none";
							activePage = false;
						}
						active.classList.remove("activeFaction");
						selectedFaction = parseInt(element.name);
						element.classList.add("activeFaction");
						
						for(var k in faction_members[selectedFaction]) {
							if(faction_members[selectedFaction][k][1] == parseInt(viewerID)) {
								leaderType = parseInt(faction_members[selectedFaction][k][3]);
								viewerRank = parseInt(faction_members[selectedFaction][k][2])-1;
							}
						}
						
						navigateToPage(1);
					}
				}
			}
		}
		if(activePage == translatePages[2]) {
			var c = document.getElementById("memberlist").childNodes;
			var selected = false;
			if(c.length > 0) {
				for(var i = 0; i < c.length; i++) {
					if(c[i].id == element.id) {
						if(selectedElement != element.id) {
							if(selectedElement > -1) {
								var activeElement = document.getElementById("member"+selectedElement);
								activeElement.classList.remove("activeMember");
								var memberDetails = document.getElementById("memberDetails");
								var memberActions = document.getElementById("memberActions");
								memberDetails.style.display = "none";
								selectedElement = -1
							}
							selectedElement = parseInt(element.name);
							element.classList.add("activeMember");
							loadMemberDetails();
							selected = true;
						} else {
							return;
						}
					}
				}
			}
			if(!selected && selectedElement > -1 && element.parentElement.id != "memberActions") {
				var activeElement = document.getElementById("member"+selectedElement);
				activeElement.classList.remove("activeMember");
				var memberDetails = document.getElementById("memberDetails");
				var memberActions = document.getElementById("memberActions");
				memberDetails.style.display = "none";
				selectedElement = -1
			}
		} else if(activePage == translatePages[3]) {
			var c = document.getElementById("vehiclelist").childNodes;
			var selected = false;
			if(c.length > 0) {
				for(var i = 0; i < c.length; i++) {
					if(c[i].id == element.id) {
						if(selectedElement != element.id) {
							if(selectedElement > -1) {
								var activeElement = document.getElementById("vehicle"+selectedElement);
								activeElement.classList.remove("activeVehicle");
								var vehicleDetails = document.getElementById("vehicleDetails");
								var vehicleActions = document.getElementById("vehicleActions");
								vehicleDetails.style.display = "none";
								vehicleActions.style.display = "none";
								selectedElement = -1
							}
							selectedElement = parseInt(element.name);
							element.classList.add("activeVehicle");
							loadVehicleDetails();
							selected = true;
						} else {
							return;
						}
					}
				}
			}
			if(!selected && selectedElement > -1 && element.parentElement.id != "vehicleActions") {
				var activeElement = document.getElementById("vehicle"+selectedElement);
				activeElement.classList.remove("activeVehicle");
				var vehicleDetails = document.getElementById("vehicleDetails");
				var vehicleActions = document.getElementById("vehicleActions");
				vehicleDetails.style.display = "none";
				vehicleActions.style.display = "none";
				selectedElement = -1
			}
		} else if(activePage == translatePages[4]) {
			var c = document.getElementById("ranklist").childNodes;
			var selected = false;
			if(c.length > 0) {
				for(var i = 0; i < c.length; i++) {
					if(c[i].id == element.id) {
						if(selectedElement != element.id) {
							if(selectedElement > -1) {
								var activeElement = document.getElementById("rank"+selectedElement);
								activeElement.classList.remove("activeRank");
								var rankDetails = document.getElementById("rankDetails");
								var rankActions = document.getElementById("rankActions");
								rankDetails.style.display = "none";
								// rankActions.style.display = "none";
								selectedElement = -1
							}
							selectedElement = parseInt(element.name);
							element.classList.add("activeRank");
							loadRankDetails();
							selected = true;
						} else {
							return;
						}
					}
				}
			}
			if(!selected && selectedElement > -1 && element.parentElement.id != "rankActionlist") {
				var activeElement = document.getElementById("rank"+selectedElement);
				activeElement.classList.remove("activeRank");
				var rankDetails = document.getElementById("rankDetails");
				var rankActions = document.getElementById("rankActions");
				rankDetails.style.display = "none";
				// rankActions.style.display = "none";
				selectedElement = -1
			}
		} else if(activePage == translatePages[5]) {
			var c = document.getElementById("storageList").childNodes;
			var selected = false;
			if(c.length > 0) {
				for(var i = 0; i < c.length; i++) {
					if(c[i].id == element.id) {
						if(selectedElement != element.id) {
							if(selectedElement > -1) {
								var activeElement = document.getElementById("storage"+selectedElement);
								activeElement.classList.remove("activeItem");
								var storageDetails = document.getElementById("storageDetails");
								var storageActions = document.getElementById("storageActions");
								storageDetails.style.display = "none";
								storageActions.style.display = "none";
								selectedElement = -1
							}
							selectedElement = parseInt(element.name);
							element.classList.add("activeItem");
							loadItemDetails();
							selected = true;
						} else {
							return;
						}
					}
				}
			}
			if(!selected && selectedElement > -1 && element.parentElement.id != "storageActions") {
				var activeElement = document.getElementById("storage"+selectedElement);
				activeElement.classList.remove("activeItem");
				var storageDetails = document.getElementById("storageDetails");
				var storageActions = document.getElementById("storageActions");
				storageDetails.style.display = "none";
				storageActions.style.display = "none";
				selectedElement = -1
			}
		} else if(activePage == translatePages[6]) { 
			var c = document.getElementById("dutyList").childNodes;
			var selected = false;
			if(c.length > 0) {
				for(var i = 0; i < c.length; i++) {
					if(c[i].id == element.id) {
						if(selectedElement != element.id) {
							if(selectedElement > -1) {
								var activeElement = document.getElementById("duty"+selectedElement);
								activeElement.classList.remove("activeDutyElement");
								var dutyDetails = document.getElementById("dutyDetails");
								var dutyActions = document.getElementById("dutyActions");
								dutyDetails.style.display = "none";
								dutyActions.style.display = "none";
								selectedElement = -1
							}
							selectedElement = parseInt(element.name);
							element.classList.add("activeDutyElement");
							loadDutyDetails();
							selected = true;
						} else {
							return;
						}
					}
				}
			}
			if(!selected && selectedElement > -1 && element.parentElement.id != "dutyActions") {
				var activeElement = document.getElementById("duty"+selectedElement);
				activeElement.classList.remove("activeDutyElement");
				var dutyDetails = document.getElementById("dutyDetails");
				var dutyActions = document.getElementById("dutyActions");
				dutyDetails.style.display = "none";
				dutyActions.style.display = "none";
				selectedElement = -1
			}
		}
	} else {
		if(activeDutyPanel) {
			var c = document.getElementById("itemList").childNodes;
			var selected = false;
			if(c.length > 0) {
				for(var i = 0; i < c.length; i++) {
					if(c[i].id == element.id) {
						if(selectedList != element.id) {
							if(selectedList > -1) {
								var activeElement = document.getElementById("itemList"+selectedList);
								if(activeElement) {	
									activeElement.classList.remove("activeItem");
								}
								var addButton = document.getElementById("addButton");
								addButton.style.display = "none";
								var listItemCount = document.getElementById("listItemCount");
								listItemCount.style.display = "none";
								selectedList = -1
							}
							var addButton = document.getElementById("addButton");
							addButton.style.display = "block";
							var listItemCount = document.getElementById("listItemCount");
							listItemCount.style.display = "block";
							selectedList = parseInt(element.name);
							element.classList.add("activeItem");
							selected = true;
						} else {
							return;
						}
					}
				}
			}
			if(!selected && selectedList > -1 && element.parentElement.id != "addButton" && element.id != "listItemCount") {
				var activeElement = document.getElementById("itemList"+selectedList);
				if(activeElement) {	
					activeElement.classList.remove("activeItem");
				}
				var addButton = document.getElementById("addButton");
				addButton.style.display = "none";
				var listItemCount = document.getElementById("listItemCount");
				listItemCount.style.display = "none";
				selectedList = -1
			}
			
			c = document.getElementById("selectedItems").childNodes;
			selected = false;
			if(c.length > 0) {
				for(var i = 0; i < c.length; i++) {
					if(c[i].id == element.id) {
						if(selectedItem != element.id) {
							if(selectedItem > -1) {
								var activeElement = document.getElementById("selectedItem"+selectedItem);
								if(activeElement) {	
									activeElement.classList.remove("activeItem");
								}
								var removeButton = document.getElementById("removeButton");
								removeButton.style.display = "none";
								selectedItem = -1
							}
							var removeButton = document.getElementById("removeButton");
							removeButton.style.display = "block";
							selectedItem = parseInt(element.name);
							element.classList.add("activeItem");
							selected = true;
						} else {
							return;
						}
					}
				}
			}
			if(!selected && selectedItem > -1 && element.parentElement.id != "removeButton") {
				var activeElement = document.getElementById("selectedItem"+selectedItem);
				if(activeElement) {	
					activeElement.classList.remove("activeItem");
				}
				var removeButton = document.getElementById("removeButton");
				removeButton.style.display = "none";
				selectedItem = -1
			}
		}
	}
}, false);

function loadMemberDetails() {
	var memberDetails = document.getElementById("memberDetails");
	var perm = hasPermission("canSeeMemberDetails", false);
	if(!perm && leaderType == 0) {
		mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canSeeMemberDetails"]);
	}
	memberDetails.style.display = perm && "block" || "none" || leaderType > 0 && "block" || "none";
	
	var detailRank = document.getElementById("detailRank");
	var detailIsLeader = document.getElementById("detailIsLeader");
	var detailSalary = document.getElementById("detailSalary");
	var detailJoined = document.getElementById("detailJoined");
	var detailLastPlace = document.getElementById("detailLastPlace");
	
	detailRank.innerHTML = "<font color='#0081c7'>"+translateRank(faction_members[selectedFaction][selectedElement][2])+"</font>";
	detailIsLeader.innerHTML = (faction_members[selectedFaction][selectedElement][3] == 0 && "<font color='red'>Nem" || faction_members[selectedFaction][selectedElement][3] == 1 && "<font color='green'>Igen" || faction_members[selectedFaction][selectedElement][3] == 2 && "<font color='green'>Igen</font> <font color='orange'>(Fő leader)") +"</font>";
	detailSalary.innerHTML = "$"+factions[selectedFaction]["ranks"][faction_members[selectedFaction][selectedElement][2]-1][1];
	detailJoined.innerHTML = "<font color='#0081c7'>" + (faction_members[selectedFaction][selectedElement][5] == false && "Most" || faction_members[selectedFaction][selectedElement][5]) + "</font>";
	detailLastPlace.innerHTML = "Ismeretlen";
}

function loadVehicleDetails() {
	var vehicleActions = document.getElementById("vehicleActions");
	var perm = hasPermission("canAccessVehicleActions", false);
	if(!perm && leaderType == 0) {
		mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canAccessVehicleActions"]);
	}
	vehicleActions.style.display = perm && "block" || "none" || leaderType > 0 && "block" || "none";
	var vehicleDetails = document.getElementById("vehicleDetails");
	var perm = hasPermission("canSeeVehicleDetails", false);
	if(!perm && leaderType == 0) {
		mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canSeeVehicleDetails"]);
	}
	vehicleDetails.style.display = perm && "block" || "none" || leaderType > 0 && "block" || "none";
	
	var vehicleIDCell = document.getElementById("vehicleID");
	vehicleIDCell.innerHTML = "<font color='orange'>" + faction_vehicles[selectedFaction][selectedElement][2] + "</font>";
	
	var vehicleLocation = document.getElementById("vehicleLocation");
	vehicleLocation.innerHTML = faction_vehicles[selectedFaction][selectedElement][1] != "Ismeretlen" && "<font color='orange'>"+faction_vehicles[selectedFaction][selectedElement][1]+"</font>" || "Ismeretlen";
}

function loadRankDetails() {
	var rankDetails = document.getElementById("rankDetails");
	var perm = hasPermission("canSeeRankDetails", false);
	if(!perm && leaderType == 0) {
		mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canSeeRankDetails"]);
	}
	rankDetails.style.display = perm && "block" || "none" || leaderType > 0 && "block" || "none";
	
	var rankName = document.getElementById("rankName");
	rankName.innerHTML = "<font color='orange'>" + factions[selectedFaction]["ranks"][selectedElement][0] + "</font>";
	
	var rankSalary = document.getElementById("rankSalary");
	rankSalary.innerHTML = "Fizetés: <font color='orange'>$</font>" + factions[selectedFaction]["ranks"][selectedElement][1];
}

function loadItemDetails() {
	var storageActions = document.getElementById("storageActions");
	var perm = hasPermission("canAccessStorageActions", false);
	if(!perm && leaderType == 0) {
		mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canAccessStorageActions"]);
	}
	storageActions.style.display = perm && "block" || "none" || leaderType > 0 && "block" || "none";
	var storageDetails = document.getElementById("storageDetails");
	var perm = hasPermission("canSeeItemDetails", false);
	if(!perm && leaderType == 0) {
		mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canSeeItemDetails"]);
	}
	storageDetails.style.display = perm && "block" || "none" || leaderType > 0 && "block" || "none";
	
	var itemCountDetail = document.getElementById("itemCountDetail");
	var count = 0;
	for(var key in factions[selectedFaction]["storage"][selectedElement]["quantities"]) {
		count = count + factions[selectedFaction]["storage"][selectedElement]["quantities"][key][2];
	}
	itemCountDetail.innerHTML = count;
}

function loadDutyDetails() {
	var dutyActions = document.getElementById("dutyActions");
	var perm = hasPermission("canAccessDutyActions", false);
	if(!perm && leaderType == 0) {
		mta.triggerEvent("showBox", "error", "Nincs jogosultságod ehhez: "+translatePermission["canAccessDutyActions"]);
	}
	dutyActions.style.display = perm && "block" || "none" || leaderType > 0 && "block" || "none";
	
	var dutyDetails = document.getElementById("dutyDetails");
	dutyDetails.style.display = "block";
	
	var dutyName = document.getElementById("dutyName");
	dutyName.innerHTML = factions[selectedFaction]["dutys"][selectedElement]["name"];
	
	var dutyDate = document.getElementById("dutyDate");
	var date = new Date(factions[selectedFaction]["dutys"][selectedElement]["created"]*1000);
	var year = date.getFullYear();
	var month = "0" + (parseInt(date.getMonth())+1);
	var day = "0" + (parseInt(date.getDay())+21);
	var hours = date.getHours();
	var minutes = "0" + date.getMinutes();
	var seconds = "0" + date.getSeconds();
	
	var formattedTime = year+'.'+month.substr(-2)+'.'+day.substr(-2)+'. ' + hours + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);
	dutyDate.innerHTML = " <font color='orange'>"+formattedTime+"</font>";
	
	var dutyRank = document.getElementById("dutyRank");
	dutyRank.innerHTML = translateRank(parseInt(factions[selectedFaction]["dutys"][selectedElement]["rank"]));
}

window.addEventListener('load', function(e) {
	// navigateToPage(1);
	// loadFactionData(1, '[ { "created": "2018-04-04 18:58:44", "type": 1, "name": "Los Santos Police Department", "id": 1, "msg": "A rendszer aktív. Örülsz mi natakaroggyáasztánörüjjébaszodmertezsokmunkavoltmosttesztelemascrollbart", "money": 1000, "ranks": [ ["Pusztító", 69], ["Nagyember", 420] ] } ]');
	// loadFactionDatas(2, '[ { "created": "2016-01-12 16:22:12", "type": 1, "name": "Ppélópáló debug frakció", "id": 2, "msg": "Dikaz rendszer futaz?", "money": 6969420 } ]');
	// loadFactionMembers(1, '[ [ { "id": 25, "joined": "#", "name": "Thomas Clark", "rank": 1, "online": 0 }, { "id": 26, "joined": "#", "name": "Debug Béla", "rank": 1, "online": 1 } ] ]');
	// receivePlayers('[ [ [ "Thomas Clark", 1 ], [ "Debug Béla", 2 ] ] ]');
	
	document.getElementById("usr-text").oninput = searchForPlayer;
	
	document.getElementById("rankSalaryEdit").oninput = function() {
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
	}
	
	document.getElementById("listItemCount").oninput = function() {
		if(this.value != "") {
			if(parseInt(this.value)) {
				if(this.value > 0) {
					if(this.value > 99) {
						this.value = 99;
					}
				} else {
					this.value = 1;
				}
			} else {
				this.value = 1;
			}
		}
	}
}, false);

function loadFactionData(id, data) {
	data = data[0];
	factions[id] = data;
	var factionlist = document.getElementById("factionlist");
	var newElement = document.createElement('div');
	newElement.classList.add("factionElement");
	newElement.innerHTML = data["name"];
	newElement.id = "faction"+id;
	newElement.name = id;
	factionlist.appendChild(newElement);
}

function loadFactionMembers(id, data, data2, dbid) {
	data = data[0];
	data2 = data2[0];
	faction_members[id] = data;
	faction_members_online[id] = data2;
	
	viewerID = parseInt(dbid);
	
	if(selectedFaction == 0) {
		selectedFaction = parseInt(id);
		document.getElementById("faction"+id).classList.add("activeFaction");
		
		for(var k in data) {
			if(data[k][1] == parseInt(dbid)) {
				leaderType = parseInt(data[k][3]);
				viewerRank = parseInt(data[k][2])-1;
				break;
			}
		}
		
		navigateToPage(1);
	}
}

function showInvite() {
	if(!noControl) {
		if(!spam) {
			noControl = true;
			var bg = document.getElementById("bg");
			var panel = document.getElementById("invitePanel");
			bg.classList.add("inviteBackground");
			panel.style.display = "block";
			mta.triggerEvent("getPlayers");
			document.getElementById("usr-text").value = "";
			document.getElementById("recommendation").innerHTML = "";
			spam = true;
			setInterval(function(){ spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function promote() {
	if(!noControl) {
		if(!spam) {
			if(selectedElement > -1) {
				mta.triggerEvent("promoteMember", selectedFaction, selectedElement+1);
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy tagot!");
			}
			spam = true;
			setInterval(function(){ spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function demote() {
	if(!noControl) {
		if(!spam) {	
			if(selectedElement > -1) {
				mta.triggerEvent("demoteMember", selectedFaction, selectedElement+1)
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy tagot!");
			}
			spam = true;
			setInterval(function(){ spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function toggleLeader() {
	if(!noControl) {
		if(!spam) {
			if(selectedElement > -1) {
				if(leaderType == 2) {
					mta.triggerEvent("toggleLeader", selectedFaction, selectedElement+1)
				} else {
					mta.triggerEvent("showBox", "error", "Ezt a funkciót csak a Fő leader tudja használni.");
				}
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy tagot!");
			}
			spam = true;
			setInterval(function(){ spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function kick() {
	if(!noControl) {
		if(!spam) {
			if(selectedElement > -1) {
				mta.triggerEvent("kickMember", selectedFaction, selectedElement+1)
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy tagot!");
			}
			spam = true;
			setInterval(function(){ spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
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
		setInterval(function(){ spam = false; }, 2000);
	} else {
		mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
	}
}

function closeInvitePanel() {
	noControl = false;
	var bg = document.getElementById("bg");
	var panel = document.getElementById("invitePanel");
	bg.classList.remove("inviteBackground");
	panel.style.display = "none";
}

function refreshFactionData(id, data) {
	data = data[0];
	factions[id] = data;
	contentById(activePage);
}

function refreshViewerPermissions(t) {
	leaderType = t;
}

function refreshFactionMembers(id, data, data2) {
	data = data[0];
	data2 = data2[0];
	faction_members[id] = data;
	faction_members_online[id] = data2;
	contentById(activePage);
}

function receivePlayers(data) {
	data = data[0];
	playerList = data;
}

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

function loadFactionVehicles(id, data) {
	data = data[0];
	faction_vehicles[id] = data;
}

function getKey() {
	if(!noControl) {
		if(!spam) {
			if(selectedElement > -1) {
				mta.triggerEvent("getKey", faction_vehicles[selectedFaction][selectedElement][2]);
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy járművet!");
			}
			spam = true;
			setInterval(function(){ spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function createRank() {
	if(!noControl) {
		if(!spam) {
			noControl = true;
			var bg = document.getElementById("bg");
			var panel = document.getElementById("createRankPanel");
			var c = document.getElementById("permissionContent");
			while(c.firstChild) {
				c.removeChild(c.firstChild);
			}
			bg.classList.add("inviteBackground");
			panel.style.display = "block";
			for(var key in translatePermission) {
				var newElement = document.createElement('label');
				newElement.classList.add("container");
				newElement.innerHTML = translatePermission[key] + '<input type="checkbox" value="'+key+'"><span class="checkmark"></span>';
				c.appendChild(newElement);
			}
			spam = true;
			setInterval(function(){ spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function editRank() {
	if(!noControl) {
		if(!spam) {
			if(selectedElement > -1) {
				noControl = true;
				var bg = document.getElementById("bg");
				var panel = document.getElementById("editRankPanel");
				bg.classList.add("inviteBackground");
				panel.style.display = "block";
				spam = true;
				var rankName = document.getElementById("editRankNameEdit");
				var rankSalary = document.getElementById("editRankSalaryEdit");
				rankName.value = factions[selectedFaction]["ranks"][selectedElement][0];
				rankSalary.value = factions[selectedFaction]["ranks"][selectedElement][1];
				
				rankPermissions = factions[selectedFaction]["permissions"][selectedElement] || [];
				
				var c = document.getElementById("permissionContent2");
				while(c.firstChild) {
					c.removeChild(c.firstChild);
				}
				
				for(var key in translatePermission) {
					var newElement = document.createElement('label');
					newElement.classList.add("container");
					if(rankPermissions.includes(key)) {
						newElement.innerHTML = translatePermission[key] + '<input type="checkbox" checked="checked" value="'+key+'"><span class="checkmark"></span>';
					} else {
						newElement.innerHTML = translatePermission[key] + '<input type="checkbox" value="'+key+'"><span class="checkmark"></span>';
					}
					c.appendChild(newElement);
				}
				
				setInterval(function(){ spam = false; }, 2000);
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy rangot!");
			}
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
		spam = true;
		setInterval(function(){ spam = false; }, 2000);
	}
}

function deleteRank() {
	if(!noControl) {
		if(!spam) {
			if(selectedElement > -1) {
				mta.triggerEvent("deleteRank", selectedFaction, selectedElement+1);
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy rangot!");
			}
			spam = true;
			setInterval(function(){ spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function createNewRank() {
	var rankName = document.getElementById("rankNameEdit");
	var rankSalary = document.getElementById("rankSalaryEdit");
	if(rankName.value != "") {
		if(parseInt(rankSalary.value)) {
			rankPermissions = [];
			var c = document.getElementById("permissionContent").childNodes;
			for (var i = 0; i < c.length; i++) {
				if(c[i].nodeName == "LABEL" && c[i].childNodes[1].checked) {
					rankPermissions.push(c[i].childNodes[1].value);
					console.log(c[i].childNodes[1].value);
				}
			}
			mta.triggerEvent("createRank", selectedFaction, rankName.value, rankSalary.value, JSON.stringify(rankPermissions));
		} else {
			mta.triggerEvent("showBox", "error", "A fizetés nem egy valós érték!");
		}
	} else {
		mta.triggerEvent("showBox", "error", "Ne hagyd üresen a rang neve szövegdobozt!");
	}
}

function isTheTableSame(t1, t2) {
	for(var i in t1) {
		if(t2[i] != t1[i]) {
			return false;
		}
	}
	return true;
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

function closeCreateRankPanel() {
	noControl = false;
	var bg = document.getElementById("bg");
	var panel = document.getElementById("createRankPanel");
	bg.classList.remove("inviteBackground");
	panel.style.display = "none";
	document.getElementById("rankNameEdit").value = "";
	document.getElementById("rankSalaryEdit").value = "";
	spam = true;
	setInterval(function(){ spam = false; }, 2000);
}

function saveRank() {
	var rankName = document.getElementById("editRankNameEdit");
	var rankSalary = document.getElementById("editRankSalaryEdit");
	if(rankName.value != "") {
		if(parseInt(rankSalary.value)) {
			rankPermissions = [];
			var c = document.getElementById("permissionContent2").childNodes;
			for (var i = 0; i < c.length; i++) {
				if(c[i].nodeName == "LABEL" && c[i].childNodes[1].checked) {
					rankPermissions.push(c[i].childNodes[1].value);
				}
			}
			var existingPerms = factions[selectedFaction]["permissions"][selectedElement] || [];
			if(rankName.value != factions[selectedFaction]["ranks"][selectedElement][0] || rankSalary.value != factions[selectedFaction]["ranks"][selectedElement][1] || !arraysEqual(rankPermissions, existingPerms)) {
				mta.triggerEvent("editRank", selectedFaction, selectedElement+1, rankName.value, rankSalary.value, JSON.stringify(rankPermissions));
			} else {
				mta.triggerEvent("showBox", "error", "Nem történt adatváltoztatás!");
			}
		} else {
			mta.triggerEvent("showBox", "error", "A fizetés nem egy valós érték!");
		}
	} else {
		mta.triggerEvent("showBox", "error", "Ne hagyd üresen a rang neve szövegdobozt!");
	}
}

function closeEditRankPanel() {
	noControl = false;
	var bg = document.getElementById("bg");
	var panel = document.getElementById("editRankPanel");
	bg.classList.remove("inviteBackground");
	panel.style.display = "none";
	document.getElementById("editRankNameEdit").value = "";
	document.getElementById("editRankSalaryEdit").value = "";
	spam = true;
	setInterval(function(){ spam = false; }, 2000);
}

function receiveItemNames(data) {
	data = data[0];
	itemNames = data;
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
			setInterval(function(){ spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function createDuty() {
	if(!noControl) {
		if(!spam) {
			dutyState = "create";
			var dutyPanel = document.getElementById("dutyPanel");
			dutyPanel.style.display = "block";
			noControl = true;
			var bg = document.getElementById("bg");
			bg.classList.add("inviteBackground");
			
			activeDutyPanel = true;
			
			var storageList = document.getElementById("itemList");
			while(storageList.firstChild) {
				storageList.removeChild(storageList.firstChild);
			}
			
			for(var key in factions[selectedFaction]["storage"]) {
				if(factions[selectedFaction]["storage"][key]["quantities"].length > 0) {
					var newElement = document.createElement('div');
					newElement.id = "itemList"+key;
					newElement.name = key;
					newElement.style.width = "198px";
					newElement.classList.add("storageElement");
					var count = 0;
					for(var key2 in factions[selectedFaction]["storage"][key]["quantities"]) {
						count = count + factions[selectedFaction]["storage"][key]["quantities"][key2][2];
					}
					newElement.innerHTML = itemNames[parseInt(factions[selectedFaction]["storage"][key]["quantities"][0])-1][0] + " <font color='grey'>(x"+count+")</font>";
					storageList.appendChild(newElement);
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
				dutyState = "edit";
				var dutyPanel = document.getElementById("dutyPanel");
				dutyPanel.style.display = "block";
				noControl = true;
				var bg = document.getElementById("bg");
				bg.classList.add("inviteBackground");
				
				activeDutyPanel = true;
				
				var storageList = document.getElementById("itemList");
				while(storageList.firstChild) {
					storageList.removeChild(storageList.firstChild);
				}
				
				for(var key in factions[selectedFaction]["storage"]) {
					if(factions[selectedFaction]["storage"][key]["quantities"].length > 0) {
						var newElement = document.createElement('div');
						newElement.id = "itemList"+key;
						newElement.name = key;
						newElement.style.width = "198px";
						newElement.classList.add("storageElement");
						var count = 0;
						for(var key2 in factions[selectedFaction]["storage"][key]["quantities"]) {
							count = count + factions[selectedFaction]["storage"][key]["quantities"][key2][2];
						}
						newElement.innerHTML = itemNames[parseInt(factions[selectedFaction]["storage"][key]["quantities"][0])-1][0] + " <font color='grey'>(x"+count+")</font>";
						storageList.appendChild(newElement);
					}
					count = 0;
				}
				
				var dutyNameEdit = document.getElementById("dutyNameEdit");
				dutyNameEdit.value = factions[selectedFaction]["dutys"][selectedElement]["name"];
				
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
				
				var storageList = document.getElementById("selectedItems");
				while(storageList.firstChild) {
					storageList.removeChild(storageList.firstChild);
				}
				
				for(var index in selectedItems) {
					if(selectedItems[index] != null) {
						var count2 = selectedItems[index][1];
						var newElement = document.createElement('div');
						newElement.id = "selectedItem"+index;
						newElement.name = index;
						newElement.style.width = "198px";
						newElement.classList.add("storageElement");
						
						newElement.innerHTML = itemNames[parseInt(selectedItems[index][0])-1][0] + " <font color='grey'>(x"+count2+")</font>";
						storageList.appendChild(newElement);
						count2 = 0;
					}
				}
				
				selectedList = -1;
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy tárgyat!");
			}
			spam = true;
			setInterval(function(){ spam = false; }, 2000);
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
			} else {
				mta.triggerEvent("showBox", "info", "Előbb jelölj ki egy duty-t!");
			}
			spam = true;
			setInterval(function(){ spam = false; }, 2000);
		} else {
			mta.triggerEvent("showBox", "info", "Ne ilyen gyorsan!");
		}
	}
}

function createNewDuty() {
	var dutyName = document.getElementById("dutyNameEdit").value;
	var dutyRank = document.getElementById("dutyRanks").value;
	mta.triggerEvent("createDuty", selectedFaction, dutyName, dutyRank, JSON.stringify(selectedItems));
}

function closeDutyPanel() {
	selectedItems = [];
	var dutyPanel = document.getElementById("dutyPanel");
	dutyPanel.style.display = "none";
	noControl = false;
	var bg = document.getElementById("bg");
	bg.classList.remove("inviteBackground");
	activeDutyPanel = false;
	dutyState = false;
}

function addItemToSelected() {
	var storageList = document.getElementById("selectedItems");
	while(storageList.firstChild) {
		storageList.removeChild(storageList.firstChild);
	}
	
	var count = parseInt(document.getElementById("listItemCount").value)
	if(count && count > 0) {
		for(var i in factions[selectedFaction]["storage"]) {
			if(i == selectedList) {	
				var found = false;
				for(var key in selectedItems) {
					if(selectedItems[key] != null) {
						if(factions[selectedFaction]["storage"][i]["quantities"][0][0] == selectedItems[key][0]) {
							selectedItems[key][1] = selectedItems[key][1]+count;
							found = true;
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
				var newElement = document.createElement('div');
				newElement.id = "selectedItem"+index;
				newElement.name = index;
				newElement.style.width = "198px";
				newElement.classList.add("storageElement");
				
				newElement.innerHTML = itemNames[parseInt(selectedItems[index][0])-1][0] + " <font color='grey'>(x"+count2+")</font>";
				storageList.appendChild(newElement);
				count2 = 0;
			}
		}
		
		var activeElement = document.getElementById("itemList"+selectedList);
		activeElement.classList.remove("activeItem");
		var addButton = document.getElementById("addButton");
		addButton.style.display = "none";
		var listItemCount = document.getElementById("listItemCount");
		listItemCount.style.display = "none";
		selectedList = -1
	} else {
		mta.triggerEvent("showBox", "error", "Darabszámnak valós értéket adj meg!");
	}
}

function removeFromSelected() {
	var storageList = document.getElementById("selectedItems");
	while(storageList.firstChild) {
		storageList.removeChild(storageList.firstChild);
	}
	
	if(selectedItems[selectedItem] != null) {
		selectedItems[selectedItem] = null;
	}
	
	for(var key in selectedItems) {
		if(selectedItems[key] != null) {
			var count = selectedItems[key][1];
			var newElement = document.createElement('div');
			newElement.id = "selectedItem"+key;
			newElement.name = key;
			newElement.style.width = "198px";
			newElement.classList.add("storageElement");
			newElement.innerHTML = itemNames[parseInt(selectedItems[key][0])-1][0] + " <font color='grey'>(x"+count+")</font>";
			storageList.appendChild(newElement);
			count = 0;
		}
		
	}
	
	var activeElement = document.getElementById("selectedItem"+selectedItem);
	if(activeElement) {	
		activeElement.classList.remove("activeItem");
	}
	var removeButton = document.getElementById("removeButton");
	removeButton.style.display = "none";
	selectedItem = -1
}

function editSelectedDuty() {
	var dutyName = document.getElementById("dutyNameEdit").value;
	var dutyRank = document.getElementById("dutyRanks").value;
	mta.triggerEvent("editDuty", selectedFaction, selectedElement+1, dutyName, dutyRank, JSON.stringify(selectedItems));
}

function saveDuty() {
	if(dutyState == "create") {
		createNewDuty();
	} else {
		editSelectedDuty()
	}
}