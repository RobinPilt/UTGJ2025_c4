extends Control

@export var npc_name_label_path: NodePath
@export var npc_blurb_label_path: NodePath
@export var marry_button_path: NodePath

@onready var npc_name_label: Label = get_node(npc_name_label_path)
@onready var npc_blurb_label: Label = get_node(npc_blurb_label_path)
@onready var marry_button: Button = get_node(marry_button_path)

var npc_data: Dictionary = {}
var current_name: String = "Robin"  # Replace with RunData.get_display_name() later

func bootstrap(payload: Dictionary) -> void:
	npc_data = payload.get("npc", {}) as Dictionary
	current_name = payload.get("full_name", current_name) as String

func _ready() -> void:
	var display_name: String = npc_data.get("display_name", "???") as String
	var family_name: String = npc_data.get("family_name", "") as String
	var blurb: String = npc_data.get("blurb", "") as String

	npc_name_label.text = "You married: %s (%s)" % [display_name, family_name]
	npc_blurb_label.text = blurb

	marry_button.pressed.connect(_on_marry_pressed)

func _on_marry_pressed() -> void:
	var new_full_name: String = "%s-%s" % [current_name, npc_data.get("family_name", "") as String]
	GameState.goto(GameState.FlowState.DATING_APP, {
		"full_name": new_full_name
	})
