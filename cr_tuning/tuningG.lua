markerPositions = {
	{-15.17013168335, 35.977687835693, 1.1096496582031},
	{-1515.3972167969, 723.40356445313, 4.7515845298767},
	{1510.8927001953, -2602.7214355469, 11.546875},
};

clonePosition = {-1656.4720458984, 1211.0985107422, 20.718938827515};
cameraPosition = {-1659.8334960938, 1204.6257324219, 21.132957458496, -1610.16796875, 1291.0163574219, 12.76674747467, 10, 70};

tuningMarkers = {};

allowedTypes = {
	["Automobile"] = true,	
};

availableWheelSizes = {
	["front"] = {
		["verynarrow"] = {0x100, 1},
		["narrow"] = {0x200, 2},
		["wide"] = {0x400, 4},
		["verywide"] = {0x800, 5},
	},

	["rear"] = {
		["verynarrow"] = {0x1000, 1},
		["narrow"] = {0x2000, 2},
		["wide"] = {0x4000, 4},
		["verywide"] = {0x8000, 5},
	}
};

availableTunings = {
	[1] = {
		["categoryName"] = "Teljesítmény",
		
		["subMenu"] = {
			[1] = {
				["categoryName"] = "Motor",
				["upgradeData"] = "veh.engine",
				["cameraSettings"] = {"bonnet_dummy", 110, 15, 6, true},
				["handlingFlags"] = {{"engineAcceleration", 0.6}, {"maxVelocity", 9.5}, {"dragCoeff", -0.05}},

				["subMenu"] = {
					[1] = {["categoryName"] = "Gyári csomag", ["tuningPrice"] = 0, ["priceIgMoney"] = true},
					[2] = {["categoryName"] = "Utcai csomag", ["tuningPrice"] = 3200 , ["priceIgMoney"] = true},
					[3] = {["categoryName"] = "Profi csomag", ["tuningPrice"] = 4800 , ["priceIgMoney"] = true},
					[4] = {["categoryName"] = "Verseny csomag", ["tuningPrice"] = 7900 , ["priceIgMoney"] = true},
					[5] = {["categoryName"] = "Gear csomag", ["tuningPrice"] = 800  , ["priceIgMoney"] = false}
				}
			},

			[2] = {
				["categoryName"] = "Turbó",
				["upgradeData"] = "veh.turbo",
				["cameraSettings"] = {"bonnet_dummy", 110, 15, 6, true},
				["handlingFlags"] = {{"engineAcceleration", 0.6}},

				["subMenu"] = {
					[1] = {["categoryName"] = "Gyári csomag", ["tuningPrice"] = 0, ["priceIgMoney"] = true},
					[2] = {["categoryName"] = "Utcai csomag", ["tuningPrice"] = 3300, ["priceIgMoney"] = true},
					[3] = {["categoryName"] = "Profi csomag", ["tuningPrice"] = 4900, ["priceIgMoney"] = true},
					[4] = {["categoryName"] = "Verseny csomag", ["tuningPrice"] = 8400, ["priceIgMoney"] = true},
					[5] = {["categoryName"] = "Gear csomag", ["tuningPrice"] = 800, ["priceIgMoney"] = false}
				}
			},

			[3] = {
				["categoryName"] = "Váltó",
				["upgradeData"] = "veh.gearbox",
				["handlingFlags"] = {{"maxVelocity", 6}},

				["subMenu"] = {
					[1] = {["categoryName"] = "Gyári csomag", ["tuningPrice"] = 0, ["priceIgMoney"] = true},
					[2] = {["categoryName"] = "Utcai csomag", ["tuningPrice"] = 3000, ["priceIgMoney"] = true},
					[3] = {["categoryName"] = "Profi csomag", ["tuningPrice"] = 5200, ["priceIgMoney"] = true},
					[4] = {["categoryName"] = "Verseny csomag", ["tuningPrice"] = 9400, ["priceIgMoney"] = true},
					[5] = {["categoryName"] = "Gear csomag", ["tuningPrice"] = 800, ["priceIgMoney"] = false}
				}
			},

			[4] = {
				["categoryName"] = "ECU",
				["upgradeData"] = "veh.ecu",
				["handlingFlags"] = {{"dragCoeff", -0.2}},

				["subMenu"] = {
					[1] = {["categoryName"] = "Gyári csomag", ["tuningPrice"] = 0, ["priceIgMoney"] = true},
					[2] = {["categoryName"] = "Utcai csomag", ["tuningPrice"] = 3500, ["priceIgMoney"] = true},
					[3] = {["categoryName"] = "Profi csomag", ["tuningPrice"] = 5100, ["priceIgMoney"] = true},
					[4] = {["categoryName"] = "Verseny csomag", ["tuningPrice"] = 9500, ["priceIgMoney"] = true},
					[5] = {["categoryName"] = "Gear csomag", ["tuningPrice"] = 800, ["priceIgMoney"] = false}
				}				
			},


			[5] = {
				["categoryName"] = "Gumik",
				["upgradeData"] = "veh.tires",
				["cameraSettings"] = {"wheel_rb_dummy", 60, 10, 4},
				["handlingFlags"] = {{"tractionMultiplier", 0.05}, {"tractionLoss", 0.02}},

				["subMenu"] = {
					[1] = {["categoryName"] = "Gyári csomag", ["tuningPrice"] = 0, ["priceIgMoney"] = true},
					[2] = {["categoryName"] = "Utcai csomag", ["tuningPrice"] = 2500, ["priceIgMoney"] = true},
					[3] = {["categoryName"] = "Profi csomag", ["tuningPrice"] = 4000, ["priceIgMoney"] = true},
					[4] = {["categoryName"] = "Verseny csomag", ["tuningPrice"] = 5900, ["priceIgMoney"] = true},
					[5] = {["categoryName"] = "Gear csomag", ["tuningPrice"] = 800, ["priceIgMoney"] = false}
				}
			},

			[6] = {
				["categoryName"] = "Fékek",
				["upgradeData"] = "veh.brakes",
				["handlingFlags"] = {{"brakeDeceleration", 0.02}, {"brakeBias", 0.08}},
				["cameraSettings"] = {"wheel_rf_dummy", 35, 5, 2, true},


				["subMenu"] = {
					[1] = {["categoryName"] = "Gyári csomag", ["tuningPrice"] = 0, ["priceIgMoney"] = true},
					[2] = {["categoryName"] = "Utcai csomag", ["tuningPrice"] = 3000, ["priceIgMoney"] = true},
					[3] = {["categoryName"] = "Profi csomag", ["tuningPrice"] = 4200, ["priceIgMoney"] = true},
					[4] = {["categoryName"] = "Verseny csomag", ["tuningPrice"] = 6900, ["priceIgMoney"] = true},
					[5] = {["categoryName"] = "Gear csomag", ["tuningPrice"] = 800, ["priceIgMoney"] = false}
				}
			}
		}
	},

	[2] = {
		["categoryName"] = "Optika",
		["availableUpgrades"] = {},

		["subMenu"] = {
			-- default tunings
			[1] = {["categoryName"] = "Első lökhárító", ["upgradeSlot"] = 14, ["tuningPrice"] = 2200, ["cameraSettings"] = {"bump_front_dummy", 130, 10, 6}},
			[2] = {["categoryName"] = "Hátsó lökhárító", ["upgradeSlot"] = 15, ["tuningPrice"] = 2200, ["cameraSettings"] = {"door_lf_dummy", -65, 3, 8}},
			[3] = {["categoryName"] = "Motorháztető", ["upgradeSlot"] = 0, ["tuningPrice"] = 1800},
			[4] = {["categoryName"] = "Kipufogó", ["upgradeSlot"] = 13, ["tuningPrice"] = 1900, ["cameraSettings"] = {"door_lf_dummy", -65, 3, 8}},
			[5] = {["categoryName"] = "Légterelő", ["upgradeSlot"] = 2, ["tuningPrice"] = 2000, ["cameraSettings"] = {"boot_dummy", -65, 3, 8}},
			[6] = {["categoryName"] = "Kerekek", ["upgradeSlot"] = 12, ["tuningPrice"] = 2200},
			[7] = {["categoryName"] = "Küszöb", ["upgradeSlot"] = 3, ["tuningPrice"] = 2200, ["cameraSettings"] = {"ug_wing_right", 65, 3, 4}},
			[8] = {["categoryName"] = "Tetőlégterelő", ["upgradeSlot"] = 7, ["tuningPrice"] = 2400},
			[9] = {["categoryName"] = "Hidraulika", ["upgradeSlot"] = 9, ["tuningPrice"] = 10},
		}
	},

	[3] = {
		["categoryName"] = "Fényezés",

		["subMenu"] = {
			[1] = {["categoryName"] = "Első szín", ["tuningPrice"] = 4000},
			[2] = {["categoryName"] = "Második szín", ["tuningPrice"] = 4000},
			[3] = {["categoryName"] = "Izzó világítás", ["tuningPrice"] = 4000}
		}
	},

	[4] = {
		["categoryName"] = "Extrák",

		["subMenu"] = {
			[1] = {
				["categoryName"] = "Első kerék",
				["upgradeData"] = "wheelsize_f",

				["subMenu"] = {
					[1] = {["categoryName"] = "Extra keskeny", ["tuningPrice"] = 6000, ["priceIgMoney"] = true, ["tuningData"] = "verynarrow"},
					[2] = {["categoryName"] = "Keskeny", ["tuningPrice"] = 4000, ["priceIgMoney"] = true, ["tuningData"] = "narrow"},
					[3] = {["categoryName"] = "Normál", ["tuningPrice"] = 2000, ["priceIgMoney"] = true, ["tuningData"] = "default"},
					[4] = {["categoryName"] = "Széles", ["tuningPrice"] = 4000, ["priceIgMoney"] = true, ["tuningData"] = "wide"},
					[5] = {["categoryName"] = "Extra széles", ["tuningPrice"] = 6000, ["priceIgMoney"] = true, ["tuningData"] = "verywide"}
				}
			},

			[2] = {
				["categoryName"] = "Hátsó kerék",
				["upgradeData"] = "wheelsize_r",

				["subMenu"] = {
					[1] = {["categoryName"] = "Extra keskeny", ["tuningPrice"] = 6000, ["priceIgMoney"] = true, ["tuningData"] = "verynarrow"},
					[2] = {["categoryName"] = "Keskeny", ["tuningPrice"] = 4000, ["priceIgMoney"] = true, ["tuningData"] = "narrow"},
					[3] = {["categoryName"] = "Normál", ["tuningPrice"] = 2000, ["priceIgMoney"] = true, ["tuningData"] = "default"},
					[4] = {["categoryName"] = "Széles", ["tuningPrice"] = 4000, ["priceIgMoney"] = true, ["tuningData"] = "wide"},
					[5] = {["categoryName"] = "Extra széles", ["tuningPrice"] = 6000, ["priceIgMoney"] = true, ["tuningData"] = "verywide"}
				}
			},

			[3] = {
				["categoryName"] = "LSD ajtó",
				["subMenu"] = {
					[1] = {["categoryName"] = "Kiszerelés", ["tuningPrice"] = 0, ["priceIgMoney"] = true, ["tuningData"] = false},
					[2] = {["categoryName"] = "Felszerelés", ["tuningPrice"] = 1200, ["priceIgMoney"] = false, ["tuningData"] = true}
				}
			},	

			[4] = {
				["categoryName"] = "Paintjob",
				["upgradeData"] = "paintjob", 

				["subMenu"] = {}
			},				
			
			[5] = {
				["categoryName"] = "Air-Ride",
				["cameraSettings"] = {"wheel_rf_dummy", 35, 5, 2, true},
				["upgradeSlot"] = 17,
				["subMenu"] = {
					[1] = {["categoryName"] = "Kiszerelés", ["tuningPrice"] = 0, ["priceIgMoney"] = true, ["tuningData"] = false},
					[2] = {["categoryName"] = "Felszerelés", ["tuningPrice"] = 8000, ["priceIgMoney"] = true, ["tuningData"] = true}
				}
			},	
			
			[6] = {
				["categoryName"] = "Meghajtás",
				["cameraSettings"] = {"wheel_rf_dummy", 35, 5, 2, true},
				["upgradeSlot"] = 17,
				["subMenu"] = {
					[1] = {["categoryName"] = "Elsőkerék meghajtás", ["tuningPrice"] = 7000, ["priceIgMoney"] = true, ["tuningData"] = "fwd"},
					[2] = {["categoryName"] = "Összkerék meghajtás", ["tuningPrice"] = 10000, ["priceIgMoney"] = true, ["tuningData"] = "awd"},
					[3] = {["categoryName"] = "Hátsókerék meghajtás", ["tuningPrice"] = 7000, ["priceIgMoney"] = true, ["tuningData"] = "rwd"}
				}
			},				
			
			[7] = {
				["categoryName"] = "Variáns",
				["subMenu"] = {
					[1] = {["categoryName"] = "Kiszerelés", ["tuningPrice"] = 0, ["priceIgMoney"] = true, ["tuningData"] = 255},
					[2] = {["categoryName"] = "Variáns 1", ["tuningPrice"] = 10000, ["priceIgMoney"] = true, ["tuningData"] = 0},
					[3] = {["categoryName"] = "Variáns 2", ["tuningPrice"] = 10000, ["priceIgMoney"] = true, ["tuningData"] = 1},
					[4] = {["categoryName"] = "Variáns 3", ["tuningPrice"] = 10000, ["priceIgMoney"] = true, ["tuningData"] = 2},
					[5] = {["categoryName"] = "Variáns 4", ["tuningPrice"] = 10000, ["priceIgMoney"] = true, ["tuningData"] = 3},
					[6] = {["categoryName"] = "Variáns 5", ["tuningPrice"] = 10000, ["priceIgMoney"] = true, ["tuningData"] = 4},
					[7] = {["categoryName"] = "Variáns 6", ["tuningPrice"] = 10000, ["priceIgMoney"] = true, ["tuningData"] = 5},
					[8] = {["categoryName"] = "Variáns 7", ["tuningPrice"] = 10000, ["priceIgMoney"] = true, ["tuningData"] = 6},
				}
			},				
			
			[8] = {
				["categoryName"] = "Fordulási szög",
				["cameraSettings"] = {"wheel_rf_dummy", 35, 5, 2, true},
				["upgradeSlot"] = 17,
				["subMenu"] = {
					[1] = {["categoryName"] = "Kiszerelés", ["tuningPrice"] = 0, ["priceIgMoney"] = true, ["tuningData"] = false},
					[2] = {["categoryName"] = "30°", ["tuningPrice"] = 2000, ["priceIgMoney"] = true, ["tuningData"] = 30},
					[3] = {["categoryName"] = "40°", ["tuningPrice"] = 2500, ["priceIgMoney"] = true, ["tuningData"] = 40},
					[4] = {["categoryName"] = "50°", ["tuningPrice"] = 3000, ["priceIgMoney"] = true, ["tuningData"] = 50},
					[5] = {["categoryName"] = "60°", ["tuningPrice"] = 3500, ["priceIgMoney"] = true, ["tuningData"] = 60}
				}
			},

			[9] = {
				["categoryName"] = "Rendszám",
				["cameraSettings"] = {"door_lf_dummy", -65, 3, 8},
				["upgradeSlot"] = 17,
				["subMenu"] = {
				},
			},				
			
			[10] = {
				["categoryName"] = "Neon",
				["cameraSettings"] = {"chassis_dummy", 0, 3, 10},
				["upgradeSlot"] = 19,

				["subMenu"] = {
					[1] = {["categoryName"] = "Kiszerelés", ["tuningPrice"] = 0,["priceIgMoney"] = true, ["tuningData"] = false},
					[2] = {["categoryName"] = "Fehér", ["tuningPrice"] = 5000, ["priceIgMoney"] = true, ["tuningData"] = "white"},
					[3] = {["categoryName"] = "Kék", ["tuningPrice"] = 5000, ["priceIgMoney"] = true, ["tuningData"] = "blue"},
					[4] = {["categoryName"] = "Zöld", ["tuningPrice"] = 5000, ["priceIgMoney"] = true,["tuningData"] = "green"},
					[5] = {["categoryName"] = "Piros", ["tuningPrice"] = 5000, ["priceIgMoney"] = true,["tuningData"] = "red"},
					[6] = {["categoryName"] = "Citromsárga", ["tuningPrice"] = 5000, ["priceIgMoney"] = true, ["tuningData"] = "yellow"},
					[7] = {["categoryName"] = "Rózsaszín", ["tuningPrice"] = 5000, ["priceIgMoney"] = true, ["tuningData"] = "pink"},
					[8] = {["categoryName"] = "Narancssárga", ["tuningPrice"] = 5000, ["priceIgMoney"] = true, ["tuningData"] = "orange"},
					[9] = {["categoryName"] = "Világoskék", ["tuningPrice"] = 5000, ["priceIgMoney"] = true, ["tuningData"] = "lightblue"},
				}
			},				
		}
	}
};