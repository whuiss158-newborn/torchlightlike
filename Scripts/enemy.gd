extends CharacterBody2D

@export var enemy_move_speed = 20

@onready var sp2d = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = enemy_move_speed * direction
	if velocity.x > 0.1:
		sp2d.flip_h = true
	elif velocity.x < -0.1:
		sp2d.flip_h = false
	move_and_slide()
