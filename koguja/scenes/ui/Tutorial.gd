extends Button

var popup: PopupPanel
var text_label: RichTextLabel
var back_btn: Button

func _ready() -> void:
	self.pressed.connect(_on_tutorial_pressed)

	# Create the popup
	popup = PopupPanel.new()
	popup.name = "TutorialPopup"
	add_child(popup)

	# Create main layout container
	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(560, 320)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	popup.add_child(vbox)

	# Create the RichTextLabel
	text_label = RichTextLabel.new()
	text_label.bbcode_enabled = false
	text_label.text = "Find your ideal date, make it to their planet avoiding hazards and collecting enough hearts on the way. Marry them and disregard their feelings, divorcing to gain new surnames with unique powerups.\n\nMovement: W, A, S, D\n\nNavigation: Enter"
	text_label.custom_minimum_size = Vector2(540, 200)
	text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(text_label)

	# Add spacer (optional)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# Back button inside a horizontal container
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(hbox)

	var h_spacer := Control.new()
	h_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(h_spacer)

	back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.size_flags_horizontal = Control.SIZE_FILL
	hbox.add_child(back_btn)

	back_btn.pressed.connect(_on_back_pressed)

func _on_tutorial_pressed() -> void:
	if popup:
		popup.popup_centered(Vector2(560, 320))

func _on_back_pressed() -> void:
	if popup:
		popup.hide()
