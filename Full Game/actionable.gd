extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String
@export var auto_trigger: bool = false       # Toggle for auto-triggering dialogue
@export var custom_balloon_scene: PackedScene
@export var dialogue_exceptions: Array[String] = ["Northern Barrier", "Southern Barrier", "Eastern Barrier", "Western Barrier"]
@onready var animated_character : AnimatedSprite2D = null
var npc_animator: AnimatedSprite2D = null

var was_activated: bool = false
var player_ref: Node = null
var dialogue_connected: bool = false
var original_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func action() -> void:
	var is_exception = name in dialogue_exceptions
	
	if was_activated and not is_exception:
		print("Dialogue already triggered for this object. Skipping.")
		return
		
	var parent_node = get_parent()
	print(parent_node)
	
	var parent_to_boolean = {
		"Victory Bell": "bell",
		"Merlin": "tree",
		"Founders": "waffle",
		"Bridge": "heart",
		"Loke Hall Flag": "flag",
		"Laybirinth": "maze",
	}
	
	if parent_to_boolean.has(parent_node.name):
		var global_key = parent_to_boolean[parent_node.name]
		if Global.get(global_key) == true:
			print("Acheivement already active")
		elif Global.get(global_key) == false:
			Global.set(global_key, true)
			print("%s activated! Set Global.%s = true" % [parent_node.name, global_key])
			if parent_node.name == "Victory Bell":
				_show_corner_popup(1)
			elif parent_node.name == "Loke Hall Flag":
				_show_corner_popup(2)
			elif parent_node.name == "Laybirinth":
				_show_corner_popup(3)
			elif parent_node.name == "Bridge":
				_show_corner_popup(4)
			else:
				_show_corner_popup(0)
		else:
			print("Parent '%s' not tracked in mapping." % parent_node.name)
		
	if parent_node.name == "Beacon":
		Global.Beacon = true
		print("Beacon activated")
	
	if parent_node.name == "Blaze":
		Global.Blaze = true
		print("Blaze activated")
		
	# Manual trigger (e.g. player presses interact key)
	if not player_ref:
		# Try to find the player automatically if not already set
		var candidate = get_tree().get_first_node_in_group("player")
		if candidate and candidate is CharacterBody2D:
			player_ref = candidate

	if not player_ref:
		push_warning("No player reference found for dialogue interaction.")
		return
		
	#HANDLE THE NPC (The Parent of this Area2D)
	var npc = get_parent()
	if npc is CharacterBody2D:
		npc.set_process(false) # Stop NPC movement/AI
		
		# Look for the sprite specifically on the NPC
		var npc_sprite = npc.get_node_or_null("AnimatedSprite2D")
		if npc_sprite and npc_sprite is AnimatedSprite2D:
			if npc_sprite.sprite_frames.has_animation("Interact"):
				animated_character = player_ref.get_node("anichar")
				npc_sprite.play("Interact")
				_freeze_player()
				animated_character.play("Idle")			
				print("NPC playing Interact animation")
				await npc_sprite.animation_finished
			elif npc_sprite.sprite_frames.has_animation("Idle"):
				npc_sprite.play("Idle")
				print("Interact not found, falling back to Idle")
			else:
				push_warning("Neither 'Interact' nor 'Idle' animations found on NPC.")

	if dialogue_resource:
		animated_character = player_ref.get_node("anichar")
		was_activated = true
		
		_freeze_player()
		_show_dialogue()
		animated_character.play("Idle")

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
		
	var is_exception = name in dialogue_exceptions
		
	if was_activated and not is_exception:
		return

	player_ref = body
	animated_character = body.get_node("anichar")
	was_activated = true
	_freeze_player()
	_show_dialogue()
	animated_character.play("Idle")

func _show_dialogue() -> void:
	if not dialogue_resource:
		return

	var balloon: Node
	
	if custom_balloon_scene:
		# 1. Manual instantiation for custom balloons
		balloon = custom_balloon_scene.instantiate()
		get_tree().root.add_child(balloon)
		balloon.start(dialogue_resource, dialogue_start)
	else:
		# 2. Use the built-in helper for the default balloon
		balloon = DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
	
	# 3. Ensure the balloon exists, then connect to its exit signal
	if balloon:
		dialogue_connected = true
		# We connect to tree_exited so that when the balloon is freed, 
		# the player is automatically unfrozen.
		balloon.tree_exited.connect(_on_dialogue_ended)

func _on_dialogue_ended() -> void:
	# This will now fire accurately when the balloon node is removed from the scene tree
	_unfreeze_player()
	player_ref = null
	dialogue_connected = false
	var npc = get_parent()
	if npc is CharacterBody2D:
		npc.set_process(true)

func _freeze_player() -> void:
	if player_ref and player_ref is CharacterBody2D:
		original_velocity = player_ref.velocity
		player_ref.velocity = Vector2.ZERO
		player_ref.set_physics_process(false)


func _unfreeze_player() -> void:
	if player_ref and player_ref is CharacterBody2D:
		player_ref.set_physics_process(true)
		player_ref.velocity = original_velocity
	
func _show_corner_popup(anim_index: int) -> void: # 0 corresponds to ACHIEVEMENT
	var popup_scene = preload("res://achievement.tscn")
	var popup = popup_scene.instantiate()
	
	get_tree().root.add_child(popup)
	popup.layer = 10
	
	# Access the enum from the script attached to the popup
	popup.show_popup(anim_index)


func _on_animated_sprite_2d_animation_finished() -> void:
	_unfreeze_player()
	var npc = get_parent()
	if npc is CharacterBody2D:
		npc.set_process(true)
