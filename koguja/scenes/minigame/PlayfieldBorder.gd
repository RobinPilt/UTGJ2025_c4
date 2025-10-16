# res://scripts/ui/PlayfieldBorder.gd
extends Panel

@export var border_color: Color = Color(0.95, 0.95, 1.0, 0.9)
@export var border_width: int = 3
@export var bg_color: Color = Color(0.02, 0.05, 0.05, 0.08) # subtle fill
@export var corner_radius: int = 0
@export var shadow_size: int = 12
@export var shadow_color: Color = Color(0, 0, 0, 0.2)

func _ready() -> void:
    var sb := StyleBoxFlat.new()
    sb.bg_color = bg_color
    sb.border_color = border_color
    sb.border_width_left = border_width
    sb.border_width_top = border_width
    sb.border_width_right = border_width
    sb.border_width_bottom = border_width
    sb.corner_radius_top_left = corner_radius
    sb.corner_radius_top_right = corner_radius
    sb.corner_radius_bottom_left = corner_radius
    sb.corner_radius_bottom_right = corner_radius
    sb.shadow_size = shadow_size
    sb.shadow_color = shadow_color
    add_theme_stylebox_override("panel", sb)