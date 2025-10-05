# res://scripts/minigame/SpaceBackground.gd
extends ParallaxBackground

@export var texture: Texture2D
@export var speed: float = 60.0
@export var direction: Vector2 = Vector2(0, 1)         # scroll down
@export var fit_to_viewport_width: bool = true         # scale sprite to fill screen width (keep aspect)
@export var repeat_x: bool = false                     # set true if your sprite isn't wide enough

# Internals
var _layer: ParallaxLayer = null
var _a: Sprite2D = null
var _b: Sprite2D = null

func _ready() -> void:
	_ensure_nodes()
	var vp: Viewport = get_viewport()
	if vp:
		vp.size_changed.connect(_on_viewport_resized)
	_apply_texture_and_layout()

func _process(delta: float) -> void:
	if _layer == null:
		return
	var dir := direction
	if dir.length() == 0.0:
		return
	dir = dir.normalized()
	_layer.motion_offset += dir * speed * delta

func _on_viewport_resized() -> void:
	_apply_texture_and_layout()

# --------------------------
# Node setup
# --------------------------
func _ensure_nodes() -> void:
	# Ensure a ParallaxLayer exists
	for c in get_children():
		if c is ParallaxLayer:
			_layer = c
			break
	if _layer == null:
		_layer = ParallaxLayer.new()
		_layer.name = "Layer"
		add_child(_layer)

	# Ensure two sprites: A (normal) and B (alternate)
	_a = _layer.get_node_or_null("A") as Sprite2D
	if _a == null:
		_a = Sprite2D.new()
		_a.name = "A"
		_layer.add_child(_a)

	_b = _layer.get_node_or_null("B") as Sprite2D
	if _b == null:
		_b = Sprite2D.new()
		_b.name = "B"
		_layer.add_child(_b)

# --------------------------
# Layout & mirroring
# --------------------------
func _apply_texture_and_layout() -> void:
	if _layer == null or texture == null:
		return

	# Assign texture and base props
	for s in [_a, _b]:
		s.texture = texture
		s.centered = false
		s.rotation = 0.0
		s.flip_h = false
		s.flip_v = false
		s.position = Vector2.ZERO
		s.scale = Vector2.ONE

	# Scale to viewport width (keeps aspect)
	var scale_x: float = 1.0
	if fit_to_viewport_width:
		var vp_size: Vector2 = get_viewport().get_visible_rect().size
		scale_x = vp_size.x / float(texture.get_width())

	_a.scale = Vector2(scale_x, scale_x)
	_b.scale = Vector2(scale_x, scale_x)

	# Tile size on screen (after scale)
	var tile_w: float = float(texture.get_width())  * scale_x
	var tile_h: float = float(texture.get_height()) * scale_x

	# Place the pair: A then B below it
	_a.position = Vector2(0.0, 0.0)
	_b.position = Vector2(0.0, tile_h)

	# Alternate look: B = rotate 180 + flip_h  ==  flip_v
	# (This yields the seamless edge you found.)
	_b.flip_v = true

	# Mirroring: repeat the AB pair (two tiles tall)
	var mirror_x: float = tile_w if repeat_x else 0.0
	var mirror_y: float = tile_h * 2.0
	_layer.motion_mirroring = Vector2(mirror_x, mirror_y)
