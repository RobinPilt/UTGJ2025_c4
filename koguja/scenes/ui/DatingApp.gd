# res://scripts/ui/DatingApp.gd
extends Control

@onready var title_lbl: Label          = $"MarginContainer/VBoxContainer/TitleLabel"
@onready var card_grid: GridContainer  = $"MarginContainer/VBoxContainer/CardGrid"
@onready var back_btn: Button          = $"MarginContainer/VBoxContainer/HBoxContainer/BackButton"

var mock_npcs: Array[Dictionary] = [
	{
		"display_name": "Zara of Andromeda",
		"family_name": "Andross",
		"difficulty_id": "easy",
		"blurb": "Chatty pilot who loves nebula picnics."
	},
	{
		"display_name": "Blorblax the Kind",
		"family_name": "Blorblax",
		"difficulty_id": "normal",
		"blurb": "Soft-spoken gelatinous poet."
	},
	{
		"display_name": "Captain K’Varr",
		"family_name": "Kvarr",
		"difficulty_id": "hard",
		"blurb": "Star navy ace; danger magnet."
	},
]

func _ready() -> void:
	title_lbl.text = "Swipe the Stars"
	back_btn.pressed.connect(_on_back_pressed)
	_populate_cards()

func _populate_cards() -> void:
	for c in card_grid.get_children():
		c.queue_free()

	for npc in mock_npcs:
		var btn: Button = _make_npc_button(npc)
		card_grid.add_child(btn)

func _make_npc_button(npc: Dictionary) -> Button:
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
