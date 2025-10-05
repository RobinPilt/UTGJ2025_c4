# res://scripts/ui/Divorce.gd
extends Control

@onready var npc_sprite: TextureRect = $NPCSprite
@onready var npc_name_label: Label = $NPCNameLabel
@onready var npc_blurb_label: Label = $NPCBlurbLabel
@onready var divorce_button: Button = $DivorceButton

var npc_data: Dictionary = {}
var current_name: String = ""  # fallback name (will already include the wedding's change)
var _payload: Dictionary = {}  # NEW: store and forward the payload intact
var text_index: int = 0
var next_btn: Button = null

func bootstrap(payload: Dictionary) -> void:
	_payload = payload.duplicate(true)
	npc_data = _payload.get("npc", {}) as Dictionary
	current_name = _payload.get("full_name", current_name) as String
	print("Divorce bootstrap received payload:", _payload)

	_setup_ui()

func _setup_ui() -> void:
	print("Setting up UI with NPC data:", npc_data)

	var display_name: String = npc_data.get("display_name", "???") as String
	var family_name: String = npc_data.get("family_name", "") as String
	var sprite_path: String = npc_data.get("sprite_path", "") as String

	# prepare text index and NextButton
	text_index = 0
	next_btn = get_node_or_null("NextButton") as Button

	if next_btn:
		next_btn.visible = true
		divorce_button.visible = false
		if not next_btn.pressed.is_connected(_on_next_pressed):
			next_btn.pressed.connect(_on_next_pressed)
	else:
		divorce_button.visible = true

	# Ensure divorce_button is connected once
	if not divorce_button.pressed.is_connected(_on_divorce_pressed):
		divorce_button.pressed.connect(_on_divorce_pressed)

	_display_current_text("divorce_text")

	npc_name_label.text = "You divorce: %s (%s)" % [display_name, family_name]

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

func _on_divorce_pressed() -> void:
	var new_full_name: String = "%s-%s" % [current_name, npc_data.get("family_name", "") as String]

	# Forward the SAME payload with the updated name back to the app (or next step)
	var next_payload: Dictionary = _payload.duplicate(true)
	next_payload["full_name"] = new_full_name
	# Keep npc if you want the app to know who you just divorced (optional)
	next_payload["npc"] = npc_data

	GameState.goto(GameState.FlowState.DATING_APP, next_payload)

# helper: always return an Array[String] for the given key
func _get_text_array(d: Dictionary, key: String) -> Array:
	var v = d.get(key, [])
	if typeof(v) == TYPE_ARRAY:
		var out := []
		for e in v:
			out.append(String(e))
		return out
	return [String(v)]

# display the current sentence for the given key (ordered by text_index)
func _display_current_text(key: String = "divorce_text") -> void:
	var arr := _get_text_array(npc_data, key)
	if arr.size() == 0:
		npc_blurb_label.text = ""
		if next_btn:
			next_btn.visible = false
		divorce_button.visible = true
		return

	if text_index < 0:
		text_index = 0
	if text_index >= arr.size():
		text_index = arr.size() - 1

	npc_blurb_label.text = arr[text_index]

	if text_index >= arr.size() - 1:
		if next_btn:
			next_btn.visible = false
		divorce_button.visible = true
	else:
		if next_btn:
			next_btn.visible = true
		divorce_button.visible = false

# called when NextButton is pressed
func _on_next_pressed() -> void:
	var arr := _get_text_array(npc_data, "divorce_text")
	if arr.size() == 0:
		return
	if text_index < arr.size() - 1:
		text_index += 1
		_display_current_text("divorce_text")
