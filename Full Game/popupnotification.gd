extends CanvasLayer

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

enum Anim {
	Achievement,
	Bell,
	Flag,
	Compass,
	Heart
}

const ANIM_MAP = {
	Anim.Achievement: "Achievement",
	Anim.Bell: "Bell",
	Anim.Flag: "Flag",
	Anim.Compass: "Compass",
	Anim.Heart: "Heart"
}

const SCALE_MAP = {
	Anim.Achievement: Vector2(0.1, 0.1), 
	Anim.Bell: Vector2(0.3, 0.3),        
	Anim.Flag: Vector2(0.3, 0.3),        
	Anim.Compass: Vector2(0.3, 0.3),
	Anim.Heart: Vector2(0.3, 0.3)
}

@export var lifetime := 2.0  # seconds before disappearing
@export var position_offset := Vector2(-50, -50)  # offset from bottom-right corner

func _ready() -> void:
	sprite.visible = false

func show_popup(type: Anim) -> void:
	var anim_name = ANIM_MAP.get(type, "Achievement")
	# If the type isn't in the map, it defaults to (1.0, 1.0)
	sprite.scale = SCALE_MAP.get(type, Vector2(1.0, 1.0))
	
	# Verify the animation exists in the SpriteFrames resource
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		printerr("Animation ", anim_name, " not found in SpriteFrames!")
		sprite.play("default")

	sprite.visible = true

	# Wait one frame to ensure textures are loaded
	await get_tree().process_frame

	sprite.position = Vector2(150, 200)  # Adjust these values for your viewport resolution

	# Fade in and out tween
	sprite.modulate = Color(1, 1, 1, 0)
	var tween := get_tree().create_tween()
	tween.tween_property(sprite, "modulate:a", 1.0, 0.25)
	tween.tween_interval(lifetime)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
	tween.finished.connect(Callable(self, "queue_free"))
