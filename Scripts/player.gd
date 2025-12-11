extends CharacterBody2D


const SPEED = 40
var attack_speed = 1
var attack_speed_growth = 1.3
var player_level = 1
var cur_exp = 0
var upgrade_exp = 1

@onready var sprite = $Sprite2D
@onready var attack_cool_down_timer: Timer = $Attack/AttackCoolDownTimer
@onready var experience_bar: TextureProgressBar = %ExperienceBar
@onready var lbl_level: Label = %lbl_level
@onready var level_up_panel: Panel = %LevelUpPanel

var iceSpear = preload("res://Scenes/ice_spear.tscn")
var upgradeCard = preload("res://Scenes/upgrade_card_item.tscn")
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


func _on_exp_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		if area.has_method("collect"):
			var get_exp = area.call("collect", self)
			handle_get_experience(get_exp)

func calculate_upgrade_expericence():
	if player_level < 5:
		return player_level * 5
	elif player_level < 10:
		return player_level * 10
	else	:
		return 400 + player_level * 30
	
func handle_get_experience(exp: int):
	cur_exp += exp
	while cur_exp >= upgrade_exp:
		player_level += 1
		handle_level_up()
		cur_exp -= upgrade_exp
		upgrade_exp = calculate_upgrade_expericence()
	update_experience_bar_status()

func handle_level_up():
	var card_container = level_up_panel.get_node("container_card")
	level_up_panel.visible = true
	var cardAmount = 3
	var i = 1
	while i <= cardAmount:
		var card = upgradeCard.instantiate()
		card_container.add_child(card)
		i -= 1
	attack_speed = attack_speed * attack_speed_growth
	attack_cool_down_timer.wait_time = 1 / attack_speed
	print(attack_cool_down_timer.wait_time)
	get_tree().paused = true
	
func update_experience_bar_status():
	experience_bar.value = cur_exp 
	experience_bar.max_value = upgrade_exp
	lbl_level.text = str("Level ", player_level)
		
