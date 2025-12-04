extends CharacterBody2D

@export var enemy_move_speed = 20

@onready var player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = enemy_move_speed * direction
	move_and_slide()
