extends CharacterBody2D

@export var enemy_move_speed = 20
@export var knockback_recovery := 3.5
@onready var sp2d = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var sound_hit: AudioStreamPlayer2D = $sound_hit
@onready var explosion_anim = preload("res://Scenes/explosion.tscn")
@onready var experience = preload("res://Scenes/experience.tscn")

signal remove_object_from_list(object)

var hp = 10
var knockback = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	velocity = enemy_move_speed * direction
	velocity += knockback
	if direction.x > 0.1:
		sp2d.flip_h = true
	elif direction.x < -0.1:
		sp2d.flip_h = false
	move_and_slide()

func death():
	remove_object_from_list.emit(self)
	var enemy_death = explosion_anim.instantiate()
	enemy_death.scale = sp2d.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	spawn_exp()
	queue_free()
	
func spawn_exp():
	var exp = experience.instantiate()
	exp.scale = sp2d.scale
	exp.global_position = global_position
	get_parent().call_deferred("add_child", exp)

func _on_hurt_box_take_damage(damage: int, hitPosition: Vector2, knockback_amount) -> void:
	hp -= damage
	knockback = (global_position - hitPosition).normalized() * knockback_amount
	if hp <= 0:
		death()
	else:
		sound_hit.play()
		
