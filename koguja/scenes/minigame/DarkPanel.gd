# res://scripts/ui/DarkPanel.gd
extends PanelContainer

@export var bg_color: Color = Color(0.02, 0.02, 0.04, 0.65)   # dark, semi-transparent
@export var border_color: Color = Color(1, 1, 1, 0.08)        # faint border (optional)
@export var border_width: int = 0                              # set >0 for a thin border
@export var corner_radius: int = 0
@export var content_padding: int = 12                          # inner padding for children

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

	# Content margins so children get padded nicely
	sb.content_margin_left = float(content_padding)
	sb.content_margin_right = float(content_padding)
	sb.content_margin_top = float(content_padding)
	sb.content_margin_bottom = float(content_padding)

	add_theme_stylebox_override("panel", sb)
