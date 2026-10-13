extends CharacterBody2D

var speed = 400
var change_direction_interval = 2.0
var target_direction = Vector2.ZERO
var direction_timer = 0.0

# The probability (0.0 to 1.0) that the NPC stays idle
@export var idle_chance: float = 0.3 

# Reference to the AnimatedSprite2D node
@onready var _animated_sprite = $AnimatedSprite2D

func _ready():
	choose_random_direction()
	
func _process(delta):
	direction_timer += delta

	if direction_timer > change_direction_interval:
		choose_random_direction()
		direction_timer = 0.0

	velocity = target_direction * speed
	
	# Play the correct animation based on movement
	if _animated_sprite:
		update_animation()
	
	move_and_slide()

func choose_random_direction():
	# Roll the dice: if the random value is less than our idle_chance, stay still
	if randf() < idle_chance:
		target_direction = Vector2.ZERO
	else:
		# Otherwise, pick a movement direction as before
		var random_angle = randf_range(0, 2 * PI)
		target_direction = Vector2(cos(random_angle), sin(random_angle))

func update_animation():
	# If target_direction is ZERO, the NPC is idling
	if target_direction == Vector2.ZERO:
		_animated_sprite.play("Idle") # Ensure you have an animation named "Idle"
	else:
		# Determine if movement is more horizontal or vertical
		if abs(target_direction.x) > abs(target_direction.y):
			# Horizontal movement
			if target_direction.x > 0:
				_animated_sprite.play("Right")
			else:
				_animated_sprite.play("Left")
		else:
			# Vertical movement
			if target_direction.y > 0:
				_animated_sprite.play("Forward")
			else:
				_animated_sprite.play("Backward")
