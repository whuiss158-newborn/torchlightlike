extends CharacterBody2D

@export var enemy_move_speed = 20

@onready var sp2d = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("player")

var hp = 10

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = enemy_move_speed * direction
	if velocity.x > 0.1:
		sp2d.flip_h = true
	elif velocity.x < -0.1:
		sp2d.flip_h = false
	move_and_slide()


func _on_hurt_box_take_damage(damage: int) -> void:
	hp -= damage
	print("get damage", damage)
	if hp <= 0:
		queue_free()
