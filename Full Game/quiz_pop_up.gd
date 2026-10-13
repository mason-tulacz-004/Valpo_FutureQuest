extends Area2D

@onready var window_node = get_parent().get_node("Area2D/CanvasLayer/Quiz")
var player_ref: Node = null
var original_velocity: Vector2 = Vector2.ZERO
signal quiz_opened

func _ready() -> void:
	var music_layer = get_tree().root.find_child("Grass", true, false)
	if music_layer:
		quiz_opened.connect(music_layer._on_quiz_started)
	else:
		push_warning("Music Layer not found! Music won't swap.")

func action() -> void:
	if not player_ref:
		# Try to find the player automatically if not already set
		var candidate = get_tree().get_first_node_in_group("player")
		if candidate and candidate is CharacterBody2D:
			player_ref = candidate

	if not player_ref:
		push_warning("No player reference found for dialogue interaction.")
		return
		
	_freeze_player()
	quiz_opened.emit()
	window_node.show()

func _freeze_player() -> void:
	if player_ref and player_ref is CharacterBody2D:
		original_velocity = player_ref.velocity
		player_ref.velocity = Vector2.ZERO
		player_ref.set_physics_process(false)
