# res://scripts/core/Main.gd
extends Node

@onready var screen_root: Node = $ScreenRoot
@onready var transition: CanvasLayer = $Transition

func _ready() -> void:
    # Register the mount point for screens
    ScreenRouter.setup(screen_root, transition)
    # Start at the main menu (will show a placeholder for now)
    GameState.goto(GameState.FlowState.MAIN_MENU)