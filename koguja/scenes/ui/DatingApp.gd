# res://scripts/ui/DatingApp.gd
extends Control

@onready var title_lbl: Label          = $"MarginContainer/VBoxContainer/TitleLabel"
@onready var card_grid: GridContainer  = $"MarginContainer/VBoxContainer/CardGrid"
@onready var back_btn: Button          = $"MarginContainer/VBoxContainer/HBoxContainer/BackButton"

var mock_npcs: Array[Dictionary] = [
	{
		"display_name": "Foxa",
		"family_name": "Andross",
		"difficulty_id": "easy",
		"blurb": "Chatty pilot who loves nebula picnics.",
		"sprite_path": "res://assets/art/char/foxa.png"
	},
	{
		"display_name": "Lucy",
		"family_name": "Blorblax",
		"difficulty_id": "normal",
		"blurb": "Soft-spoken gelatinous poet.",
		"sprite_path": "res://assets/art/char/lucy.png"
	},
	{
		"display_name": "Saask",
		"family_name": "Kvarr",
		"difficulty_id": "hard",
		"blurb": "Star navy ace; danger magnet.",
		"sprite_path": "res://assets/art/char/saask.png"
	},
]

func _ready() -> void:
	randomize()  # Seed the random number generator
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

	# 👇 Explicit types to avoid Variant inference warnings
	var diff: String = (npc.get("difficulty_id", "normal") as String)
	var name: String = (npc.get("display_name", "???") as String)
	var fam:  String = (npc.get("family_name", "") as String)
	var blurb: String = (npc.get("blurb", "") as String)

	b.text = "[%s]\n%s\n— %s\n%s" % [diff.capitalize(), name, fam, blurb]

	b.pressed.connect(func() -> void:
		_on_card_pressed(npc)
	)
	return b

func _on_card_pressed(npc: Dictionary) -> void:
	GameState.goto(GameState.FlowState.MINIGAME, {"npc": npc})

func _on_back_pressed() -> void:
	GameState.goto(GameState.FlowState.MAIN_MENU)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
