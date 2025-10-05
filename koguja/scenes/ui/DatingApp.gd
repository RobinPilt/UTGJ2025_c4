# res://scripts/ui/DatingApp.gd
extends Control

@onready var title_lbl: Label          = $"MarginContainer/VBoxContainer/TitleLabel"
@onready var card_grid: GridContainer  = $"MarginContainer/VBoxContainer/CardGrid"
@onready var back_btn: Button          = $"MarginContainer/VBoxContainer/HBoxContainer/BackButton"
@onready var playerName: LineEdit	   = $"MarginContainer/VBoxContainer/PlayerName" # holds player written name and later their acquired names

# these show the max amount that these upgrades can increase the players stats
@onready var stat_increases = {
	"heartBonus": 1,
	"healthBonus": 2,
	"timeBonus": 4
}
@onready var difficultyMults = { # just trust me bro
	"easy" = 1,
	"normal" = 1.5,
	"hard" = 2
}

var mock_npcs: Array[Dictionary] = [
	{
		"display_name": "Foxa",
		"family_name": "Fox",
		"difficulty_id": "easy",
		"blurb": "Sassy, he's your type of man, meeting is a must, he chill.",
		"sprite_path": "res://assets/art/char/foxa.png",
		"sprite_path2": "res://assets/art/char/foxablush.png",
		"wedding_art": "res://assets/art/D8316F01-AAA9-44E4-85E3-2E0F52B91CCF.png",
		"wedding_text": ["Human. Not so fast.. we can take our time. Hand in hand.", "We can take our time. hand in hand."],
		"divorce_text": ["Well i guess we are not meant to be.", "Boy."]
	},
	{
		"display_name": "Lucius",
		"family_name": "Friedemann",
		"difficulty_id": "normal",
		"blurb": "Calm, and mean, leader kinda type.",
		"sprite_path": "res://assets/art/char/lucy.png",
		"sprite_path2": "res://assets/art/char/lucyblush.png",
		"wedding_art": "res://assets/art/8B3A5B0E-B04D-4F19-96D7-0672A0D6FC1B.png",
		"wedding_text": ["This bright day should be fine for us, right?", "This glorious day should be celebrated."],
		"divorce_text": ["I assume I wasn't holy enough for a mere human.", "..."]
	},
	{
		"display_name": "Su-Jin",
		"family_name": "O",
		"difficulty_id": "hard",
		"blurb": "A bad type, liar, will take your money, snu snu, rip pelvis.",
		"sprite_path": "res://assets/art/char/saask.png",
		"sprite_path2": "res://assets/art/char/saaskblush.png",
		"wedding_art": "res://assets/art/D8316F01-AAA9-44E4-85E3-2E0F52B91CCF.png",
		"wedding_text": ["You are lucky that i like cute boys like yourself,", "you smell so sweet, just my type. *gets on one knee*"],
		"divorce_text": ["*sucks you dry*", "Thank you for the blood"]
	},
	{
		"display_name": "Aquarius",
		"family_name": "Zodiac",
		"difficulty_id": "normal",
		"blurb": "Rock hard, stoned (rock), water? this thing is also chill.",
		"sprite_path": "res://assets/art/char/aquarius.png",
		"sprite_path2": "res://assets/art/char/aquariusblush.png",
		"wedding_art": "res://assets/art/BF9C6B80-118A-480B-861C-F452E28602D8.png",
		"wedding_text": ["For some who controls the flows, ...", "this one is somewhat agreeable."],
		"divorce_text": ["Looks like this river didn't flow far enough.", "You should be ashamed."]
	},
	{
		"display_name": "Dragonika",
		"family_name": "Miki",
		"difficulty_id": "hard",
		"blurb": "Furry",
		"sprite_path": "res://assets/art/char/dragon.png",
		"sprite_path2": "res://assets/art/char/dragonblush.png",
		"wedding_art": "res://assets/art/BF9C6B80-118A-480B-861C-F452E28602D8.png",
		"wedding_text": ["You? mortal?", "I guess I can take up your offer."],
		"divorce_text": ["Divorce? FOR WHAT? you, mere human.", "*goes to cry*"]
	},
	{
		"display_name": "Rin",
		"family_name": "Kobayashigawa",
		"difficulty_id": "normal",
		"blurb": "Sadistic woman",
		"sprite_path": "res://assets/art/char/rin.png",
		"sprite_path2": "res://assets/art/char/rinblush.png",
		"wedding_art": "res://assets/art/3F470535-3182-45EE-A5A8-2C2AC87E3284.png",
		"wedding_text": ["Marriage?", "Someone like you, might be fun for a while."],
		"divorce_text": ["I guess there was no hope to begin with.", "*you lose, you become the pet*"]
	},
	{
		"display_name": "Serena",
		"family_name": "Gilbert",
		"difficulty_id": "easy",
		"blurb": "Wild woman, chemistry stuff, a bit sadistic",
		"sprite_path": "res://assets/art/char/serena.png",
		"sprite_path2": "res://assets/art/char/serenablush.png",
		"wedding_art": "res://assets/art/9024F3A8-74F1-4787-A083-766A9CAC266B.png",
		"wedding_text": ["Some one as cute as you, sure.", "For one that will be with me until the end."],
		"divorce_text": ["You....mere mortal. You should be thankful, I guess not.", "I knew you wouldn't be a good material for my research."]
	},
	{
		"display_name": "Valentin",
		"family_name": "Devilika",
		"difficulty_id": "hard",
		"blurb": "Gaslighter, manupulator, cherubim",
		"sprite_path": "res://assets/art/char/valentin.png",
		"sprite_path2": "res://assets/art/char/valentin.png",
		"wedding_art": "res://assets/art/D8316F01-AAA9-44E4-85E3-2E0F52B91CCF.png",
		"wedding_text": ["Marry? too bad...", "*grabs your arm* The thee agrees."],
		"divorce_text": [".........,", "*blast to oblivious* You dead."]
	},
	{
		"display_name": "Victor",
		"family_name": "Herman",
		"difficulty_id": "normal",
		"blurb": "Alcoholic, chill dude, fight? Yes. gambler",
		"sprite_path": "res://assets/art/char/victor.png",
		"sprite_path2": "res://assets/art/char/victorblush.png",
		"wedding_art": "res://assets/art/9024F3A8-74F1-4787-A083-766A9CAC266B.png",
		"wedding_text": ["We should go for rounds of drinks.", "On you okay?"],
		"divorce_text": ["Divorce?", "That was uncalled for yo. I wanted to get you more."]
	}
]

func _ready() -> void:
	randomize()  # Seed the random number generator
	if Globals.player_name_Locked:
		playerName.editable = false # locks the playerName
		playerName.text = Globals.player_name # shows the players full name
	title_lbl.text = "Swipe the Stars"
	back_btn.pressed.connect(_on_back_pressed)
	_populate_cards()
	
func _populate_cards() -> void:
	for c in card_grid.get_children():
		c.queue_free()

	var rolledIndexes : Array[int] = [] # holds indexes of what npcs were rolled, so we dont roll the same ones
	while rolledIndexes.size() < 3: # rolls until WE get 3 npcs	
		var random_index = randi() % mock_npcs.size() # rolls a random index for a npc
		if not rolledIndexes.has(random_index): # if the rolled index is a new npc, use it
			rolledIndexes.append(random_index)
			var npc = mock_npcs[random_index]
			var btn: Button = _make_npc_button(npc)
			card_grid.add_child(btn)
	rolledIndexes.clear()

func _make_npc_button(npc: Dictionary) -> Button: # tere
	var b := Button.new()
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# Explicit types to avoid Variant inference warnings
	var diff: String = (npc.get("difficulty_id", "normal") as String)
	var name: String = (npc.get("display_name", "???") as String)
	var fam:  String = (npc.get("family_name", "") as String)
	var blurb: String = (npc.get("blurb", "") as String)

 # 🎯 Filter eligible stats based on difficulty
	var eligible_stats: Array[String] = Globals.StatsArray.duplicate()
	if diff == "easy" or diff == "normal":
		eligible_stats.erase("heartBonus")

	# 🎲 Roll a stat from the filtered list
	var rolled_stat: String = eligible_stats[randi() % eligible_stats.size()]
	
	# 📈 Apply difficulty multiplier to base increase
	var base_increase: int = stat_increases[rolled_stat]
	var multiplier: float
	if diff == "hard":
		multiplier = 1
	else:
		multiplier = difficultyMults.get(diff, 1.0)
	var increase_value: int = int(base_increase * multiplier)
	
	#store metadata
	b.set_meta("rolled_stat", rolled_stat)
	b.set_meta("increase_value", increase_value)
	b.set_meta("npc", npc)

	b.text = "[%s]\n%s\n— %s (+%s: %s)\n%s" % [diff.capitalize(), name, fam, rolled_stat, increase_value, blurb]

	b.pressed.connect(func() -> void:
		_on_card_pressed(b)
	)
	return b
	
func _Update_PlayerName(npc: Dictionary) -> void: # i beg this works
	if !Globals.player_name_Locked: # if it is the first round, set the players name before adding to it
		Globals.player_name = playerName.text
	var npcName: String = (npc.get("family_name", "") as String)
	Globals.player_name += " " + npcName # Adds the new family name to the players name
	Globals.player_name_Locked = true # locks the player name, so it wont be able to be changed anymore, gotta get 150 words here

func _on_card_pressed(button: Button) -> void:
	var npc: Dictionary = button.get_meta("npc")
	var rolled_stat: String = button.get_meta("rolled_stat")
	var increase_value: int = button.get_meta("increase_value")
	
	if !Globals.player_name_Locked:
		Globals.player_name = playerName.text
		
		 # Apply stat bonus
	match rolled_stat:
		"heartBonus":
			Globals.heartBonus += increase_value
		"healthBonus":
			Globals.healthBonus += increase_value
		"timeBonus":
			Globals.timeBonus += increase_value
			
	GameState.goto(GameState.FlowState.MINIGAME, {"npc": npc})

func _on_back_pressed() -> void:
	GameState.goto(GameState.FlowState.MAIN_MENU)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
