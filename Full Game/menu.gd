extends CanvasLayer

@onready var _animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animated_sprite.play("Menu")

func _on_start_button_pressed():
	get_parent().show()
	hide()
	#Hide this screen and start the game.
