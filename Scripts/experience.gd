extends Area2D

@export var exp_amount = 5
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var target = null
var speed = -1

var spr_green = preload("res://Assets/Textures/Items/Gems/Gem_green.png")
var spr_blue = preload("res://Assets/Textures/Items/Gems/Gem_blue.png")
var spr_red = preload("res://Assets/Textures/Items/Gems/Gem_red.png")

func _ready() -> void:
	if exp_amount < 5:
		return
	elif exp_amount < 20:
		sprite_2d.texture = spr_blue
	else:
		sprite_2d.texture = spr_red
		
func _physics_process(delta: float) -> void:
	if not target == null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 4 * delta
		if global_position.distance_squared_to(target.global_position) < 10:
			self.hide()
			queue_free()
	
func collect(player: CharacterBody2D):
	audio_stream_player_2d.play()
	target = player
	collision_shape_2d.call_deferred("set", "disabled", true)
	animation_player.stop()
	return exp_amount
