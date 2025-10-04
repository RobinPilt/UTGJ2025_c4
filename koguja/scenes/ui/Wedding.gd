extends Control

@onready var npc_sprite: TextureRect = $NPCSprite
@onready var npc_name_label: Label = $NPCNameLabel
@onready var npc_blurb_label: Label = $NPCBlurbLabel
@onready var marry_button: Button = $MarryButton

var npc_data: Dictionary = {}
var current_name: String = "Robin"  # fallback name

func bootstrap(payload: Dictionary) -> void:
	npc_data = payload.get("npc", {}) as Dictionary
	current_name = payload.get("full_name", current_name) as String
	print("Wedding bootstrap received payload:", payload)

	_setup_ui()

func _setup_ui() -> void:
	print("Setting up UI with NPC data:", npc_data)

	var display_name: String = npc_data.get("display_name", "???") as String
	var family_name: String = npc_data.get("family_name", "") as String
	var blurb: String = npc_data.get("blurb", "") as String
	var sprite_path: String = npc_data.get("sprite_path", "") as String

	npc_name_label.text = "You married: %s (%s)" % [display_name, family_name]
	npc_blurb_label.text = blurb

	print("Trying to load sprite from path:", sprite_path)

	if sprite_path != "":
		var tex: Texture2D = load(sprite_path)
		if tex:
			npc_sprite.texture = tex
			print("Sprite loaded successfully.")
		else:
			print("Failed to load texture from path:", sprite_path)
	else:
		print("No sprite path provided.")

	marry_button.pressed.connect(_on_marry_pressed)

func _on_marry_pressed() -> void:
	var new_full_name: String = "%s-%s" % [current_name, npc_data.get("family_name", "") as String]
	GameState.goto(GameState.FlowState.DATING_APP, {
		"full_name": new_full_name
	})
