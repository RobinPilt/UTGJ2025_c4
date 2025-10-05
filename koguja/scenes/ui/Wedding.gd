# res://scripts/ui/Wedding.gd
extends Control

@onready var npc_sprite: TextureRect = $NPCSprite
@onready var npc_name_label: Label = $NPCNameLabel
@onready var npc_blurb_label: Label = $NPCBlurbLabel
@onready var marry_button: Button = $MarryButton

var npc_data: Dictionary = {}
var current_name: String = ""  # fallback name
var _payload: Dictionary = {}  # NEW: store incoming payload so we can forward it intact

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
    var wedding_text: String = npc_data.get("wedding_text", "Sample wedding text.") as String
    var sprite_path: String = npc_data.get("sprite_path2", "") as String

    npc_name_label.text = "You married: %s (%s)" % [display_name, family_name]
    npc_blurb_label.text = wedding_text

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

    # Avoid multiple connects if bootstrap runs again
    if not marry_button.pressed.is_connected(_on_marry_pressed):
        marry_button.pressed.connect(_on_marry_pressed)

func _on_marry_pressed() -> void:
    var new_full_name: String = "%s-%s" % [current_name, npc_data.get("family_name", "") as String]

    # Forward the SAME payload, only updating full_name
    var next_payload: Dictionary = _payload.duplicate(true)
    next_payload["full_name"] = new_full_name
    # Ensure npc stays in payload (it already should be, but we reinforce it)
    next_payload["npc"] = npc_data

    GameState.goto(GameState.FlowState.DIVORCE, next_payload)