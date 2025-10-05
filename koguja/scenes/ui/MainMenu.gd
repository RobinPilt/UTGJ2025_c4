# res://scripts/ui/MainMenu.gd
extends Control

@onready var start_btn: Button = $"CenterContainer/VBoxContainer/StartButton"
@onready var quit_btn: Button = $"CenterContainer/VBoxContainer/QuitButton"
@onready var settings_btn: Button = $"CenterContainer/VBoxContainer/SettingsButton"
@onready var sound = preload("res://assets/audio/ui_select.wav")

func _on_button_pressed():
	print("Pressed")
	$AudioStreamPlayer.stream = sound
	$AudioStreamPlayer.play()

func _ready() -> void:
	# Connect button signals
	start_btn.pressed.connect(_on_button_pressed)
	quit_btn.pressed.connect(_on_button_pressed)
	start_btn.pressed.connect(_on_start_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	settings_btn.pressed.connect(_on_button_pressed)

func _on_start_pressed() -> void:
	GameState.goto(GameState.FlowState.DATING_APP)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_start_pressed()
