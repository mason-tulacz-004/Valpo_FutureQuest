extends Control  # Changed from Area2D

var player_ref: Node = null
var original_velocity: Vector2 = Vector2.ZERO
@onready var end_window = self 
@onready var result_label = get_node("Result")
@onready var shield_sprite = get_node("Shield Badge")
@onready var bell_sprite = get_node("Bell Badge")
@onready var waffle_sprite = get_node("Waffle Badge")
@onready var heart_sprite = get_node("Heart Badge")
@onready var tree_sprite = get_node("Tree Badge")
@onready var flag_sprite = get_node("Book Badge")
@onready var maze_sprite = get_node("Maze Badge")
@onready var dog_sprite = get_node("Dog Badge")

const QUESTION_MARK = preload("res://Static Sprites/Black_question_mark.png")
const SHIELD_TEX = preload("res://Animations/shield_frames/shield1.png")
const BELL_TEX = preload("res://Static Sprites/Victory Bell.png")
const WAFFLE_TEX = preload("res://Static Sprites/waffles for founders.png")
const HEART_TEX = preload("res://Animations/Heart/frame_0_delay-0.5s.png")
const TREE_TEX = preload("res://Static Sprites/Merlin Spring copy.png")
const FLAG_TEX = preload("res://Animations/Loke_Flag/frame_0_delay-0.2s.png")
const MAZE_TEX = preload("res://Animations/Compass/frame_0_delay-0.35s.png")
const DOG_TEX = preload("res://Animations/Tennis_Ball/frame_0_delay-0.2s.png")

# Since this is a Control node, you might call this from a Button press
# or when the menu is opened.
func action() -> void:
# Convert the scores dictionary to an array of [category, score] pairs
	var score_list = []
	for category in Global.scores.keys():
		score_list.append([category, Global.scores[category]])

# Sort the list by score, highest first
	score_list.sort_custom(func(a, b): return a[1] > b[1])

# Take the top 3 (or fewer if there aren’t 3)
	var top_results = score_list.slice(0, min(3, score_list.size()))

# Build the display text
	var result_text = "Top Results:\n"
	for pair in top_results:
		var category = pair[0]
		var score = pair[1]
		result_text += "- " + category.capitalize() + ": " + str(score) + "\n"
	
	print(result_text)
	result_label.text = result_text
	
	var parent_node = get_parent()
	if parent_node and parent_node.name == "Torch 6":
		Global.complete = true
		print("End activated! Boolean set to true.")
		print(end_window.get_path())
		
	if not player_ref:
		# Try to find the player automatically if not already set
		var candidate = get_tree().get_first_node_in_group("player")
		if candidate and candidate is CharacterBody2D:
			player_ref = candidate

	if not player_ref:
		push_warning("No player reference found for dialogue interaction.")
		return

	_update_icons()
	#_freeze_player()
	end_window.show()


func _update_icons() -> void:
# Each key: [global_boolean_value, corresponding sprite, texture_if_true]
	var icon_data = {
	"complete": [Global.complete, shield_sprite, SHIELD_TEX],
	"bell": [Global.bell, bell_sprite, BELL_TEX],
	"waffle": [Global.waffle, waffle_sprite, WAFFLE_TEX],
	"heart": [Global.heart, heart_sprite, HEART_TEX],
	"tree": [Global.tree, tree_sprite, TREE_TEX],
	"flag": [Global.flag, flag_sprite, FLAG_TEX],
	"maze": [Global.maze, maze_sprite, MAZE_TEX],
	}

	for key in icon_data.keys():
		var value = icon_data[key]
		var is_active: bool = value[0]
		var sprite: Sprite2D = value[1]
		var active_tex: Texture2D = value[2]

		if is_active:
# Optional: resize only for shield
			if key == "complete":
				var img = active_tex.get_image()
				img.resize(500, 614)
				var resized_tex = ImageTexture.create_from_image(img)
				sprite.texture = resized_tex
			elif key == "waffle":
				var img = active_tex.get_image()
				img.resize(626, 626)
				var resized_tex = ImageTexture.create_from_image(img)
				sprite.texture = resized_tex
			elif key == "heart":
				var img = active_tex.get_image()
				img.resize(627, 627)
				var resized_tex = ImageTexture.create_from_image(img)
				sprite.texture = resized_tex
			elif key == "bell":
				var img = active_tex.get_image()
				img.resize(768, 1152)
				var resized_tex = ImageTexture.create_from_image(img)
				sprite.texture = resized_tex
			elif key == "flag":
				var img = active_tex.get_image()
				img.resize(768, 768)
				var resized_tex = ImageTexture.create_from_image(img)
				sprite.texture = resized_tex
			elif key == "maze":
				var img = active_tex.get_image()
				img.resize(768, 768)
				var resized_tex = ImageTexture.create_from_image(img)
				sprite.texture = resized_tex
			else:
				sprite.texture = active_tex
		else:
			sprite.texture = QUESTION_MARK

	if Global.Beacon && Global.Blaze:
		var img = DOG_TEX.get_image()
		img.resize(900, 900)
		var resized_tex = ImageTexture.create_from_image(img)
		dog_sprite.texture = resized_tex
		
func _freeze_player() -> void:
	if player_ref and player_ref is CharacterBody2D:
		original_velocity = player_ref.velocity
		player_ref.velocity = Vector2.ZERO
		player_ref.set_physics_process(false)
		
func _unfreeze_player() -> void:
	print("Unfreeze called")
	print(player_ref)
	var candidate = get_tree().get_first_node_in_group("player")
	if candidate and candidate is CharacterBody2D:
		player_ref = candidate
	print(player_ref)
	if player_ref and player_ref is CharacterBody2D:
		player_ref.set_physics_process(true)
		player_ref.velocity = original_velocity

func _on_exit_pressed() -> void:
	if OS.has_feature("web"):
		# Option A: Try to close the browser tab directly
		JavaScriptBridge.eval("window.close()")
		
		# Option B: Fallback redirect (Highly Recommended for Web)
		# Since browsers often block window.close() due to security settings,
		# redirecting users back to your main site or Itch.io page is much cleaner.
		# JavaScriptBridge.eval("window.location.href = 'https://yourgamepage.com';")
	else:
		# Standard exit logic for native Windows, Mac, or Linux builds
		get_tree().quit()


func _on_return_pressed() -> void:
	print(self)
	self.hide()
	_unfreeze_player()
	print("Return to game end")


func _on_exit_game_pressed() -> void:
	get_tree().quit()
