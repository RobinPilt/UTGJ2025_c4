extends CanvasLayer

@export var duration: float = 0.35  # fade-out duration (fade-in takes same time)
@onready var overlay: ColorRect = $Overlay

func _ready() -> void:
    # ensure overlay exists
    if overlay == null:
        push_error("Transition: Overlay ColorRect not found. Add a ColorRect named 'Overlay' to the scene.")
        return
    overlay.visible = false
    # start fully transparent
    var c := overlay.color
    c.a = 0.0
    overlay.color = c

# Play the transition. `midpoint_cb` is a Callable that will be called after fade-out.
# Example usage from ScreenRouter:
#   transition.call("play", Callable(self, "_do_swap"))
func play(midpoint_cb: Callable) -> void:
    if overlay == null:
        # nothing to animate; run callback immediately
        if midpoint_cb:
            midpoint_cb.call()
        return

    overlay.visible = true
    # ensure starting alpha 0
    var c := overlay.color
    c.a = 0.0
    overlay.color = c

    var tw := create_tween()
    # fade out to black
    tw.tween_property(overlay, "color:a", 1.0, duration)
    # call the provided callback at midpoint
    tw.tween_callback(func(): _on_midpoint(midpoint_cb))
    # fade back in (back to transparent)
    tw.tween_property(overlay, "color:a", 0.0, duration)
    tw.tween_callback(Callable(self, "_on_complete"))
    tw.play()

func _on_midpoint(cb: Callable) -> void:
    if cb:
        cb.call()

func _on_complete() -> void:
    overlay.visible = false