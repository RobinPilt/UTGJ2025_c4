# res://scripts/minigame/minigame.gd
extends Node2D

@onready var back_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/BackButton"
@onready var win_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/DebugWinButton"
@onready var lose_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/DebugLoseButton"
@onready var hearts_label: Label = $"HUD/UIFrame/RightPanel/HeartsLabel"
@onready var health_label: Label = $"HUD/UIFrame/LeftPanel/HealthLabel"
@onready var timer_bar: ProgressBar = $"HUD/MarginContainer/VBoxContainer/TimerBar"
@onready var spawner: Node = $Spawner

const DIFFICULTY_HEARTS = {
	"easy": 10,
	"normal": 15,
	"hard": 20
}

var npc_data: Dictionary = {}
var hearts_collected: int = 0
var required_hearts: int = 10

var max_time: float = 30.0
var time_left: float = 30.0

var health: int = 3  # Starting health

func bootstrap(payload: Dictionary) -> void:
	npc_data = payload.get("npc", {}) as Dictionary
	var difficulty_id: String = npc_data.get("difficulty_id", "easy")
	required_hearts = DIFFICULTY_HEARTS.get(difficulty_id, 10)

	match difficulty_id:
		"easy": max_time = 30.0
		"normal": max_time = 25.0
		"hard": max_time = 20.0

	time_left = max_time
	hearts_collected = 0
	health = 3
	update_heart_ui()
	update_health_ui()
	update_timer_ui()

	# Start bullet patterns for this run
	if is_instance_valid(spawner):
		if spawner.has_method("set_difficulty"):
			spawner.set_difficulty(difficulty_id)
		if spawner.has_method("start"):
			spawner.start(difficulty_id)

func _ready() -> void:
	back_btn.pressed.connect(func() -> void:
		_stop_spawner()
		GameState.goto(GameState.FlowState.DATING_APP)
	)

	win_btn.pressed.connect(func() -> void:
		_go_wedding()
	)

	lose_btn.pressed.connect(func() -> void:
		_go_graveyard()
	)

func _process(delta: float) -> void:
	time_left -= delta
	update_timer_ui()

	if time_left <= 0.0:
		_go_graveyard()

func on_heart_collected(value: int = 1) -> void:
	hearts_collected += value
	update_heart_ui()

	if hearts_collected >= required_hearts:
		_go_wedding()

func on_player_hit() -> void:
	health -= 1
	update_health_ui()

	if health <= 0:
		_go_graveyard()

func update_heart_ui() -> void:
	hearts_label.text = "Hearts: %d / %d" % [hearts_collected, required_hearts]

func update_health_ui() -> void:
	health_label.text = "Health: %d" % health

func update_timer_ui() -> void:
	timer_bar.value = (time_left / max_time) * 100.0

func _stop_spawner() -> void:
	if is_instance_valid(spawner) and spawner.has_method("stop"):
		spawner.stop()

func _go_wedding() -> void:
	_stop_spawner()
	GameState.goto(GameState.FlowState.WEDDING, {
		"npc": npc_data,
		"full_name": "Robin"
	})

func _go_graveyard() -> void:
	_stop_spawner()
	GameState.goto(GameState.FlowState.GRAVEYARD, {
		"full_name": "Robin"
	})
