# res://scripts/ui/Wedding.gd
extends Control

@onready var npc_sprite: TextureRect = $NPCSprite
@onready var npc_name_label: Label = $NPCNameLabel
@onready var npc_blurb_label: Label = $NPCBlurbLabel
@onready var marry_button: Button = $MarryButton

var npc_data: Dictionary = {}
var current_name: String = ""  # fallback name
var _payload: Dictionary = {}  # store incoming payload so we can forward it intact
var text_index: int = 0  # current sentence index for ordered texts
var next_btn: Button = null

func bootstrap(payload: Dictionary) -> void:
	_payload = payload.duplicate(true)   # keep the full incoming payload
	npc_data = _payload.get("npc", {}) as Dictionary
	current_name = _payload.get("full_name", current_name) as String
	print("Wedding bootstrap received payload:", _payload)

	_setup_ui()

func _setup_ui() -> void:
	print("Setting up UI with NPC data:", npc_data)

	var display_name: String = npc_data.get("display_name", "???") as String
	var family_name: String = npc_data.get("family_name", "") as String

	# normalize to array and show the first sentence (ordered)
	text_index = 0

	# Next button node (may or may not exist in scene)
	next_btn = get_node_or_null("NextButton") as Button

	# If there is a NextButton we start with it visible and hide the Marry button.
	# If there's no NextButton, show Marry immediately.
	if next_btn:
		next_btn.visible = true
		marry_button.visible = false
		if not next_btn.pressed.is_connected(_on_next_pressed):
			next_btn.pressed.connect(_on_next_pressed)
	else:
		# ensure marry button visible when no next exists
		marry_button.visible = true

	# Ensure marry_button is connected once
	if not marry_button.pressed.is_connected(_on_marry_pressed):
		marry_button.pressed.connect(_on_marry_pressed)

	_display_current_text("wedding_text")

	var sprite_path: String = npc_data.get("sprite_path2", "") as String
	npc_name_label.text = "You married: %s (%s)" % [display_name, family_name]
	# npc_blurb_label is set by _display_current_text already

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

func _on_marry_pressed() -> void:
	var new_full_name: String = "%s-%s" % [current_name, npc_data.get("family_name", "") as String]

	# Forward the SAME payload, only updating full_name
	var next_payload: Dictionary = _payload.duplicate(true)
	next_payload["full_name"] = new_full_name
	# Ensure npc stays in payload (it already should be, but we reinforce it)
	next_payload["npc"] = npc_data

	GameState.goto(GameState.FlowState.DIVORCE, next_payload)

# helper: always return an Array[String] for the given key
func _get_text_array(d: Dictionary, key: String) -> Array:
	var v = d.get(key, [])
	if typeof(v) == TYPE_ARRAY:
		# ensure all entries are strings
		var out := []
		for e in v:
			out.append(String(e))
		return out
	# if single string or other, return single-element array
	return [String(v)]

# display the current sentence for the given key (ordered by text_index)
func _display_current_text(key: String = "wedding_text") -> void:
	var arr := _get_text_array(npc_data, key)
	if arr.size() == 0:
		npc_blurb_label.text = ""
		# nothing to show, ensure Marry is visible and Next hidden
		if next_btn:
			next_btn.visible = false
		marry_button.visible = true
		return

	# clamp index to valid range
	if text_index < 0:
		text_index = 0
	if text_index >= arr.size():
		text_index = arr.size() - 1

	npc_blurb_label.text = arr[text_index]

	# If we've reached the last sentence, hide Next and show Marry
	if text_index >= arr.size() - 1:
		if next_btn:
			next_btn.visible = false
		marry_button.visible = true
	else:
		# still more sentences to show
		if next_btn:
			next_btn.visible = true
		marry_button.visible = false

# call this when the Next button is pressed
func _on_next_pressed() -> void:
	var arr := _get_text_array(npc_data, "wedding_text")
	if arr.size() == 0:
		# nothing to advance to
		return
	if text_index < arr.size() - 1:
		text_index += 1
		_display_current_text("wedding_text")
	# if we just arrived at last sentence, _display_current_text will hide Next and show Marry
