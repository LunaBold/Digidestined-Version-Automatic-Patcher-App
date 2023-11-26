extends Control
@onready var file_dialog = $FileDialog
@onready var errorPopup = $"No Modfiles"
@onready var no_digimon = $"No Digimon"
@onready var no_moves = $"No Moves"
@onready var no_evolutions = $"No Evolutions"
@onready var progress_bar = $ProgressBar
@onready var loading = $Loading
@onready var button = $PanelContainer/MarginContainer/VBoxContainer/Button

var currentPath = ""
var farmParapath = "/data/digimon_farm_para.mbe/digimon.csv"
var commonpath = "/data/digimon_common_para.mbe/digimon.csv"
var commandpath = "/data/battle_command.mbe/Command.csv"
var commandeffectpath = "/data/battle_command_effect.mbe/effect.csv"
var evolutionpath = "/data/evolution_condition_para.mbe/digimon.csv"
var farmPara = null

func _ready():
	file_dialog.get_vbox().set("theme_override_constants/separation", 20)
	$AnimationPlayer.play("Pulsation")
	$AnimationPlayer2.play("Loading")


func _on_file_dialog_dir_selected(path: String):
	currentPath = path
	var keys
	var foldername = "%s Digidestined" % path.split("/")[path.split("/").size()-2]
	var dir = DirAccess.open(OS.get_executable_path().get_base_dir())
	if path.split("/")[-1] != "modfiles":
		errorPopup.popup_centered()
		return
	else:
		button.disabled = true
	### SETUP FOLDERS ###
	$ProgressBar.show()
	await get_tree().create_timer(.05).timeout
	progress_bar.value = 0
	loading.show()
	dir.make_dir_recursive("%s/modfiles/data/digimon_farm_para.mbe/" % foldername)
	dir.make_dir_recursive("%s/modfiles/data/evolution_condition_para.mbe/" % foldername)
	dir = DirAccess.open(OS.get_executable_path().get_base_dir().path_join(foldername))
	await get_tree().create_timer(.05).timeout
	progress_bar.value = 10
	
	
	### GET DIGIMON LEVELS ###
	var digimonLevels = {}
	var evolutionConditionKeys : PackedStringArray = []
	if FileAccess.file_exists(currentPath+commonpath):
		### GENERATE CSV KEYS FOR EVOLUTION CONDITIONS ###
		for i in "id,condType1,condValue1,condUnk1,condType2,condValue2,condUnk2,condType3,condValue3,condUnk3,condType4,condValue4,condUnk4,condType5,condValue5,condUnk5,condType6,condValue6,condUnk6,condType7,condValue7,condUnk7,condType8,condValue8,condUnk8,condType9,condValue9,condUnk9,condType10,condValue10,condUnk10".split(","):
			evolutionConditionKeys.append(i)
		await get_tree().create_timer(.05).timeout
		progress_bar.value = 20
		### GET DIGIMON COMMON FILE TO EXTRACT LEVEL DATA ###
		var file = FileAccess.open(currentPath+commonpath, FileAccess.READ)
		var _scrap = file.get_csv_line()
		while !file.eof_reached():
			var currentLine = file.get_csv_line()
			if currentLine.size() < 2:
				continue
			digimonLevels[currentLine[0]] = currentLine[1]
	else:
		button.disabled = false
		no_digimon.popup_centered()
		progress_bar.hide()
		loading.hide()
		return
	
		### DOES THE MOD CONTAIN A FARM PARA FILE ###
	if FileAccess.file_exists(currentPath+farmParapath):
		var file = FileAccess.open(currentPath+farmParapath, FileAccess.READ)
		var database : Array[Dictionary] = [{}]
		keys = file.get_csv_line(",")
		while !file.eof_reached():
			var keyNo = 0
			var currentLine = file.get_csv_line(",")
			### GET DEM KEYS! ###
			if currentLine.size() < 2:
				continue
			else:
				database.resize(database.size()+1)
			print(currentLine)
			for i in keys:
				database[database.size()-1][i] = currentLine[keyNo]
				keyNo += 1
		farmPara = database
	else:
		button.disabled = false
		no_digimon.popup_centered()
		progress_bar.hide()
		loading.hide()
		return
	await get_tree().create_timer(.05).timeout
	progress_bar.value = 30
	### APPLY THE DIGIDESTINED PATCHED STATS ###
	for i in farmPara:
		if !i.has("id"):
			continue
		i["growthType"] = "1"
		i["memoryUse"] = "5"
		i["baseHP"] = "2000"
		i["baseSP"] = "2000"
		i["baseATK"] = "2700"
		i["baseDEF"] = "2700"
		i["baseINT"] = "2700"
		i["baseSPD"] = "2700"
		i["baseSPD"] = "2700"
		
		match int(digimonLevels[i["id"]]):
				0:
					i["maxLevel"] = "8"
				1:
					i["maxLevel"] = "15"
				2:
					i["maxLevel"] = "25"
				3:
					i["maxLevel"] = "40"
				4:
					i["maxLevel"] = "50"
				5:
					i["maxLevel"] = "70"
				6:
					i["maxLevel"] = "99"
				7:
					i["maxLevel"] = "99"
				8:
					i["maxLevel"] = "50"
				9:
					i["maxLevel"] = "50"
				10:
					i["maxLevel"] = "50"
		
		i["equipSlots"] = "3"
		
		if i["sMove1"].left(1) == ("["):
			i["move6"] = i["sMove1"].insert(i["sMove1"].length()-1, " In")
			i["move6Level"] = "40"
			print("adding inheritable version of %s" % i["sMove1"])
		elif i["move6"] != "0":
			push_warning("Digimon already has a move in their 6th slot")
		else:
			var move = null
			if MoveIdReference.moveIds.has(i["sMove1"]):
				move = MoveIdReference.moveIds[i["sMove1"]]
			if move != null:
				print("converting %s to inheritable id" % i["sMove1"])
				i["move6"] = move
				i["move6Level"] = "40"
			else:
				push_error("%s was not found in database" % i["sMove1"])
		i["growthType"] = "1"
	await get_tree().create_timer(.05).timeout
	progress_bar.value = 40
	### OPEN THE PATCHED MOD FOLDER ###
	await get_tree().create_timer(.05).timeout
	progress_bar.value = 50
	### MAKE/OPEN THE PATCHED FARMPARA FILE ###
	var farmFile = FileAccess.open(OS.get_executable_path().get_base_dir().path_join("%s/modfiles/data/digimon_farm_para.mbe/" % foldername).path_join("digimon.csv"), FileAccess.WRITE)
	var farmData : PackedStringArray = []
	for i in "id,memoryUse,growthType,unk3,baseHP,baseSP,baseATK,baseDEF,baseINT,baseSPD,maxLevel,equipSlots,supportSkill,sMove1,sMove1Level,sMove2,sMove2Level,move1,move1Level,move2,move2Level,move3,move3Level,move4,move4Level,move5,move5Level,move6,move6Level,expValue,levelCurve,profile,unk32,unk33".split(","):
		farmData.append(i)
	farmFile.store_csv_line(farmData)
	farmData = []
	await get_tree().create_timer(.05).timeout
	progress_bar.value = 60
	### FILL THE CSV ###
	for i in farmPara:
		if !i.has("id"):
			continue
		for j in keys:
			farmData.append(i[j])
		farmFile.store_csv_line(farmData)
		farmData = []
	await get_tree().create_timer(.05).timeout
	progress_bar.value = 70
	
	### Get Evolution Conditions ###
	if FileAccess.file_exists(currentPath+evolutionpath):
		var EvolutionConditionFile = FileAccess.open(OS.get_executable_path().get_base_dir().path_join("%s/modfiles/data/evolution_condition_para.mbe/" % foldername).path_join("digimon.csv"), FileAccess.WRITE)
		var EvolutionConditionData : PackedStringArray = []
		
		EvolutionConditionFile.store_csv_line(evolutionConditionKeys)
		await get_tree().create_timer(.05).timeout
		progress_bar.value = 80
		### APPLY EVOLUTION CONDITIONS DEPENDING ON LEVEL ###
		for i in digimonLevels:
			EvolutionConditionData = []
			EvolutionConditionData.append(i)
			match int(digimonLevels[i]):
				0:
					for j in "0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0".split(","):
						EvolutionConditionData.append(j)
				1:
					for j in "1,6,0,9,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0".split(","):
						EvolutionConditionData.append(j)
				2:
					for j in "1,8,0,9,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0".split(","):
						EvolutionConditionData.append(j)
				3:
					for j in "1,15,0,9,30,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0".split(","):
						EvolutionConditionData.append(j)
				4:
					for j in "1,30,0,9,60,0,11,[Item::Crest of Destiny],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0".split(","):
						EvolutionConditionData.append(j)
				5:
					for j in "1,50,0,9,80,0,11,[Item::Hand of Fate],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0".split(","):
						EvolutionConditionData.append(j)
				6:
					for j in "1,60,0,9,100,0,11,[Item::Limite Break],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0".split(","):
						EvolutionConditionData.append(j)
				7:
					for j in "1,60,0,9,100,0,11,[Item::Limite Break],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0".split(","):
						EvolutionConditionData.append(j)
				8:
					for j in "1,30,0,9,60,0,11,[Item::Crest of Destiny],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0".split(","):
						EvolutionConditionData.append(j)
				9:
					for j in "1,30,0,9,60,0,11,[Item::Crest of Destiny],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0".split(","):
						EvolutionConditionData.append(j)
				10:
					for j in "1,30,0,9,60,0,11,[Item::Crest of Destiny],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0".split(","):
						EvolutionConditionData.append(j)
			print(EvolutionConditionData)
			EvolutionConditionFile.store_csv_line(EvolutionConditionData)
		await get_tree().create_timer(.05).timeout
		progress_bar.value = 90
		if FileAccess.file_exists(currentPath+commandpath):
			dir = DirAccess.open(OS.get_executable_path().get_base_dir())
			dir.make_dir_recursive("%s/modfiles/data/battle_command.mbe/" % foldername)
			dir = DirAccess.open(OS.get_executable_path().get_base_dir().path_join(foldername))
			### DO INHERITABLES ###
			var commandFileNew = FileAccess.open(OS.get_executable_path().get_base_dir().path_join("%s/modfiles/data/battle_command.mbe/" % foldername).path_join("Command.csv"), FileAccess.WRITE)
			var commandFile = FileAccess.open(currentPath+commandpath, FileAccess.READ)
			while !commandFile.eof_reached():
				var currentLine = commandFile.get_csv_line(",")
				if currentLine.size() < 2:
					continue
				if currentLine[0].to_lower() != "id":
					currentLine[0] = currentLine[0].insert(currentLine[0].length()-1, " In")
				commandFileNew.store_csv_line(currentLine, ",")
			if FileAccess.file_exists(currentPath+commandeffectpath):
				dir = DirAccess.open(OS.get_executable_path().get_base_dir())
				dir.make_dir_recursive("%s/modfiles/data/battle_command_effect.mbe/" % foldername)
				dir = DirAccess.open(OS.get_executable_path().get_base_dir().path_join(foldername))
				var commandEffectFileNew = FileAccess.open(OS.get_executable_path().get_base_dir().path_join("%s/modfiles/data/battle_command_effect.mbe/" % foldername).path_join("effect.csv"), FileAccess.WRITE)
				var commandEffectFile = FileAccess.open(currentPath+commandeffectpath, FileAccess.READ)
				while !commandEffectFile.eof_reached():
					var currentLine = commandEffectFile.get_csv_line(",")
					if currentLine.size() < 2:
						continue
					if currentLine[0].to_lower() != "id":
						currentLine[0] = currentLine[0].insert(currentLine[0].length()-1, " In")
					commandEffectFileNew.store_csv_line(currentLine, ",")
		else:
			no_moves.popup_centered()
	else:
		button.disabled = false
		no_evolutions.popup_centered()
		progress_bar.hide()
		loading.hide()
		return
	
	await get_tree().create_timer(.05).timeout
	progress_bar.value = 95
	var Metadata = {
		"Name": "%s Digidestined Patch" % foldername,
		"Author": "Luna Bold & Mojoceramon",
		"Version": "1.0",
		"Category": "Digimon",
		"Description": "Load this after the original mod"
	}
	var metadatafile = FileAccess.open(OS.get_executable_path().get_base_dir().path_join(foldername).path_join("METADATA.json"), FileAccess.WRITE)
	metadatafile.store_line(JSON.stringify(Metadata, "	", false))
	
	var readmefile = FileAccess.open(OS.get_executable_path().get_base_dir().path_join(foldername).path_join("1. put metadata and modfiles"), FileAccess.WRITE)
	readmefile.store_line("Henlo!")
	var readmefile1 = FileAccess.open(OS.get_executable_path().get_base_dir().path_join(foldername).path_join("2. into a zip file"), FileAccess.WRITE)
	readmefile1.store_line("Henlo!")
	var readmefile2 = FileAccess.open(OS.get_executable_path().get_base_dir().path_join(foldername).path_join("3. then load using the"), FileAccess.WRITE)
	readmefile2.store_line("Henlo!")
	var readmefile3 = FileAccess.open(OS.get_executable_path().get_base_dir().path_join(foldername).path_join("4. simple mod manager"), FileAccess.WRITE)
	readmefile3.store_line("Henlo!")
	await get_tree().create_timer(.05).timeout
	progress_bar.value = 100
	
	var error = OS.shell_open(dir.get_current_dir())
	if error != OK:
		push_error("shell open error code %s" % error)
	button.disabled = false
	$Label.show()
	loading.hide()
