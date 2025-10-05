# res://scripts/ui/Graveyard.gd
extends Control

@export var name_label_path: NodePath
@export var hint_label_path: NodePath
@export var try_again_button_path: NodePath
@export var main_menu_button_path: NodePath

@onready var name_label: Label        = get_node(name_label_path) as Label
@onready var hint_label: Label        = get_node(hint_label_path) as Label
@onready var try_again_btn: Button    = get_node(try_again_button_path) as Button
@onready var main_menu_btn: Button    = get_node(main_menu_button_path) as Button
@onready var sound                    = preload("res://assets/audio/fail.wav")

var full_name: String = ""

func bootstrap(payload: Dictionary) -> void:
	# Payload from Minigame on defeat
	full_name = String(payload.get("full_name", Globals.player_name))

func _ready() -> void:
	$AudioStreamPlayer.stream = sound
	$AudioStreamPlayer.play()
	if full_name == "":
		full_name = Globals.player_name  # Set from global if not set by payload
	if name_label:
		name_label.text = full_name
	if hint_label:
		hint_label.text = "Press Enter (or click) to continue"

	if try_again_btn:
		try_again_btn.pressed.connect(func() -> void:
			GameState.goto(GameState.FlowState.DATING_APP)
	)
	if main_menu_btn:
		main_menu_btn.pressed.connect(func() -> void:
			GameState.goto(GameState.FlowState.MAIN_MENU)
	)

	Globals.player_name = ""
	Globals.player_name_Locked = false  # Reset global variable after displaying
	Globals.heartBonus = 0
	Globals.healthBonus =  0 
	Globals.timeBonus = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		GameState.goto(GameState.FlowState.DATING_APP)
