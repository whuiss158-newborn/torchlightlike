extends CharacterBody2D


const SPEED = 40
var attack_speed = 1

@onready var sprite = $Sprite2D
@onready var attack_cool_down_timer: Timer = $Attack/AttackCoolDownTimer

var iceSpear = preload("res://Scenes/ice_spear.tscn")
var enemy_close: Array[CharacterBody2D] = []

func _ready() -> void:
	attack_cool_down_timer.wait_time = 1 / attack_speed
	attack_cool_down_timer.one_shot = false
	attack()

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
	velocity = mov.normalized() * SPEED
	move_and_slide()
	
func attack():
	if attack_cool_down_timer.is_stopped():
		attack_cool_down_timer.start()

func _physics_process(delta: float) -> void:
	movement()

func _on_attack_cool_down_timer_timeout() -> void:
	if enemy_close.size() > 0:
		var iceSpearIns = iceSpear.instantiate()
		iceSpearIns.target = get_random_target()
		iceSpearIns.position = position
		add_child(iceSpearIns)

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP
	
func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if enemy_close.has(body):
		return
	else:
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_hurt_box_take_damage(damage: int) -> void:
	print("player get damage", damage)


func _on_exp_detection_area_body_entered(body: Node2D) -> void:
	print(body)
	if body.is_in_group("loot"):
		if body.has_method("collect"):
			body.call("collect")
