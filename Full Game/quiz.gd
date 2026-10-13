extends Control

var scores = {
	"realistic": 0,
	"investigative": 0,
	"artistic": 0,
	"social": 0,
	"enterprising": 0,
	"conventional": 0
}

var answers = {
	"realistic": [false, false],
	"investigative": [false, false],
	"artistic": [false, false],
	"social": [false, false],
	"enterprising": [false, false],
	"conventional": [false, false]
}

var player_ref: Node = null
var original_velocity: Vector2 = Vector2.ZERO
signal quiz_closed

@export var next_torch_path: NodePath

# Automatically wire up buttons
func _ready():
	var music_layer = get_tree().root.find_child("Grass", true, false)
	if music_layer:
		quiz_closed.connect(music_layer._on_quiz_finished)
	# Each category has 2 questions: Q1 and Q2
	for category in answers.keys():
		for i in range(answers[category].size()):
			# Build the node path dynamically
			var yes_button_path = "%s%d/YesButton" % [category.capitalize(), i+1]
			var no_button_path  = "%s%d/NoButton" % [category.capitalize(), i+1]

			var yes_button = get_node(yes_button_path)
			var no_button  = get_node(no_button_path)

			yes_button.pressed.connect(_on_answer_pressed.bind(category, i, true))
			no_button.pressed.connect(_on_answer_pressed.bind(category, i, false))

# Generic handler for button presses
func _on_answer_pressed(category: String, index: int, value: bool) -> void:
# 	1. Update the data logic
	answers[category][index] = value
	
	# 2. Get the specific pair of buttons
	var yes_node = get_node("%s%d/YesButton" % [category.capitalize(), index + 1])
	var no_node  = get_node("%s%d/NoButton" % [category.capitalize(), index + 1])
	
	# 3. Define Colors
	var brown = Color(0.39, 0.26, 0.13)
	var white = Color(1, 1, 1) # Or your original button color

	# 4. Helper function to apply colors to all states
	# This ensures the brown stays even when you move the mouse away
	_apply_button_color(yes_node, brown if value else white)
	_apply_button_color(no_node, white if value else brown)
	

# Called when submit is pressed
func _submit() -> void:
	var candidate = get_tree().get_first_node_in_group("player")
	if candidate and candidate is CharacterBody2D:
		player_ref = candidate

	if player_ref and player_ref is CharacterBody2D:
		player_ref.set_physics_process(true)
		player_ref.velocity = original_velocity
		
	hide()
	for category in scores.keys():
		scores[category] = 0  # reset score
		for ans in answers[category]:
			if ans:
				scores[category] += 1
	
		Global.scores[category] += scores[category]
	# Handle torch transitions
	_show_next_torch()
	_remove_this_torch()
	quiz_closed.emit()

func _show_next_torch() -> void:
	# Show the next torch if specified
	if next_torch_path != NodePath(""):
		var next_torch = get_node_or_null(next_torch_path)
		if next_torch:
			next_torch.show()
			
			for child in next_torch.get_children():
				if child is Area2D:
					# Restore processing
					child.process_mode = Node.PROCESS_MODE_INHERIT
					# Safely enable collision shapes
					for subchild in child.get_children():
						if subchild is CollisionShape2D or subchild is CollisionPolygon2D:
							subchild.set_deferred("disabled", false)
			print("Next torch revealed:", next_torch.name)
		else:
			print("Next torch path invalid or not found:", next_torch_path)
	else:
		print("No next_torch_path set for", name)

func _remove_this_torch() -> void:
	# Hide or free the torch node (two parents up from the quiz)
	var torch_parent = get_parent()
	if torch_parent and torch_parent.get_parent().get_parent():
		var torch_root = torch_parent.get_parent().get_parent()
		print("Removing torch:", torch_root.name)
		torch_root.hide()
		
		for child in torch_root.get_children():
			if child is Area2D:
				# Disable processing
				child.process_mode = Node.PROCESS_MODE_DISABLED
				# Safely disable collision shapes to prevent physics errors right before queue_free
				for subchild in child.get_children():
					if subchild is CollisionShape2D or subchild is CollisionPolygon2D:
						subchild.set_deferred("disabled", true)
		torch_root.queue_free()
	else:
		push_warning("Could not find torch root (expected two levels up from quiz).")
		
func _apply_button_color(button: Button, color: Color):
	button.add_theme_color_override("font_color", color)         # Normal state
	button.add_theme_color_override("font_hover_color", color)   # When mouse is over it
	button.add_theme_color_override("font_pressed_color", color) # While clicking
	button.add_theme_color_override("font_focus_color", color)   # After clicking (Focus)
