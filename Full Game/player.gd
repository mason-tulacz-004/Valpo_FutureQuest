extends CharacterBody2D


@export var speed: int
const JUMP_VELOCITY = -400.0
@onready var animated_character = $anichar
@onready var actionable_finder: Area2D = $Direction/ActionableFinder



func _ready():
	add_to_group("player")

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_accept"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			return

func _physics_process(_delta: float) -> void:
	var input_direction := Vector2.ZERO

	input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()
		velocity = input_direction * speed
		
		# Animations (Notice these are all inside the 'if moving' block)
		if input_direction.x > 0:
			animated_character.play("Walk Right")
		elif input_direction.x < 0:
			animated_character.play("Walk Left")
		elif input_direction.y < 0:
			animated_character.play("Walk Up")
		elif input_direction.y > 0:
			animated_character.play("Walk Down")
	else:
		# THIS IS THE KEY: This 'else' matches the 'if input_direction != Vector2.ZERO'
		# It triggers the moment you release all keys.
		velocity = Vector2.ZERO
		animated_character.play("Idle")

	move_and_slide()
