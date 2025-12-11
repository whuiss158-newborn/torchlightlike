extends CharacterBody2D


const SPEED = 40
var attack_speed = 1
var attack_speed_growth = 1.3
var player_level = 1
var cur_exp = 0
var upgrade_exp = 1
# 新增全局变量：记录剩余需要处理的升级次数
var remaining_level_ups: int = 0

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
	# 第一步：先计算本次总共能升多少级（仅算数值，不处理UI/属性）
	var total_level_ups = 0
	while cur_exp >= upgrade_exp:
		total_level_ups += 1
		cur_exp -= upgrade_exp
		upgrade_exp = calculate_upgrade_expericence()
	update_experience_bar_status()
	# 第二步：记录剩余升级次数，若有升级则启动第一步升级流程
	if total_level_ups > 0:
		remaining_level_ups = total_level_ups
		# 处理第一次升级（生成3张牌，暂停游戏）
		handle_level_up()

func handle_level_up():
	# 1. 升级等级，更新属性（每升1级涨一次属性）
	player_level += 1
	print("当前等级：", player_level)
	attack_speed = attack_speed * attack_speed_growth
	attack_cool_down_timer.wait_time = 1 / attack_speed
	
	# 2. 清空旧卡牌，生成新的3张牌
	var card_container = level_up_panel.get_node("container_card")
	# 先删除容器内所有旧卡牌，避免叠加
	for child in card_container.get_children():
		child.queue_free()
	# 生成3张新牌（每级固定3张）
	level_up_panel.visible = true
	for i in range(3):
		var card = upgradeCard.instantiate()
		card_container.add_child(card)
		print("生成第", i+1, "张升级卡牌")
	
	# 3. 暂停游戏，等待玩家选择
	get_tree().paused = true
	# 更新经验条（每升一级都更细）
	update_experience_bar_status()
	
func update_experience_bar_status():
	experience_bar.value = cur_exp 
	experience_bar.max_value = upgrade_exp
	lbl_level.text = str("Level ", player_level)
		
