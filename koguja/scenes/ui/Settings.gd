# res://scripts/ui/Settings.gd
extends Button

var popup: PopupPanel
var volume_slider: HSlider
var volume_label: Label
var back_btn: Button

func _ready() -> void:
	# Connect button to open the popup
	self.pressed.connect(_on_settings_pressed)

	# Build popup in code since we can't add nodes in the scene
	popup = PopupPanel.new()
	popup.name = "SettingsPopup"
	add_child(popup)

	var vbox = VBoxContainer.new()
	popup.add_child(vbox)

	# Label
	volume_label = Label.new()
	vbox.add_child(volume_label)

	# Slider
	volume_slider = HSlider.new()
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.step = 1
	vbox.add_child(volume_slider)

	# Back button
	back_btn = Button.new()
	back_btn.text = "Back"
	vbox.add_child(back_btn)

	# Connect signals
	back_btn.pressed.connect(_on_back_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)

	# Initialize volume
	var bus_idx := AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_idx)) * 100.0
	_update_volume_label()

func _on_settings_pressed() -> void:
	popup.popup_centered()

func _on_back_pressed() -> void:
	popup.hide()

func _on_volume_changed(value: float) -> void:
	var bus_idx := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))
	_update_volume_label()

func _update_volume_label() -> void:
	volume_label.text = "Volume: %d%%" % int(volume_slider.value)
