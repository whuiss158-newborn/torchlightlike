extends CharacterBody2D


var speed = 40
var attack_speed_growth = 1.3

@onready var sprite = $Sprite2D
@onready var attack_cool_down_timer: Timer = $Attack/AttackCoolDownTimer
@onready var experience_bar: TextureProgressBar = %ExperienceBar
@onready var lbl_level: Label = %lbl_level
@onready var level_up_panel: Panel = %LevelUpPanel
@onready var card_container: Control = level_up_panel.get_node("container_card")
@onready var exp_detection_area: Area2D = $ExpDetectionArea

var iceSpear = preload("res://Scenes/ice_spear.tscn")
var upgradeCard = preload("res://Scenes/upgrade_card_item.tscn")
var enemy_close: Array[CharacterBody2D] = []

func _ready() -> void:
	# 初始化：从 GameManager 获取当前攻击速度
	_update_attack_speed_from_level()
	attack_cool_down_timer.one_shot = false
	 # 关键步骤：将卡牌容器告知 GameManager
	GameManager.set_card_container(card_container)
	GameManager.player_xp_changed.connect(_on_player_xp_changed)
	GameManager.player_level_up.connect(_on_player_level_up)

	_update_experience_ui()
	attack()

func _update_attack_speed_from_level():
	var base_speed = 1.0
	var current_level = GameManager.current_level
	var calculated_speed = base_speed * pow(attack_speed_growth, current_level - 1)
	attack_cool_down_timer.wait_time = 1.0 / calculated_speed


func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
	velocity = mov.normalized() * speed
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
			GameManager.add_player_xp(get_exp)

func _on_player_xp_changed(new_xp: int, xp_needed: int):
	experience_bar.max_value = xp_needed
	experience_bar.value = new_xp

func _on_player_level_up(new_level: int):
	print("玩家升级至等级：", new_level)
	lbl_level.text = str("Level ", new_level)
	_show_level_up_cards()
	get_tree().paused = true

func _show_level_up_cards():
	for child in card_container.get_children():
		child.queue_free()
	
	level_up_panel.visible = true
	
	for i in range(3):
		var card_instance = upgradeCard.instantiate()
		var card_data = GameManager._generate_random_card_data()
		var script_holder = card_instance.get_node("Container")
		if script_holder and "card_data" in script_holder:
			script_holder.card_data = card_data
		if script_holder.has_signal("card_selected"):
			script_holder.card_selected.connect(_on_upgrade_card_selected.bind(script_holder, card_data))
		card_container.add_child(card_instance)
		print("生成第", i+1, "张升级卡牌")

func _on_upgrade_card_selected(card_node, card_data: CardData):
	print("玩家选择了卡片：", card_data.card_name)
	_apply_card_effect(card_data)
	
	level_up_panel.visible = false
	for child in card_container.get_children():
		child.queue_free()
	
	get_tree().paused = false
	_check_for_next_level_up()

func _apply_card_effect(card_data: CardData):
	match card_data.type:
		CardData.CardType.ATTACK:
			GameManager.player_attack_bonus += card_data.attack_power
			print("攻击力增加: ", card_data.attack_power)
		CardData.CardType.SPEED:
			speed += card_data.move_speed_bonus * speed
			print("移动速度增加")
		CardData.CardType.EXPERIENCE:
			exp_detection_area.scale += exp_detection_area.scale * card_data.pickup_range_bonus
			print("经验拾取增加")
		# ... 处理其他类型
		
func _check_for_next_level_up():
	if GameManager.has_pending_level_up():
		await get_tree().create_timer(0.5).timeout
		GameManager.process_next_pending_level_up()

func _update_experience_ui():
	var info = GameManager.get_level_info()
	print("info", info)
	experience_bar.value = info.current_xp
	experience_bar.max_value = info.xp_to_next_level
	lbl_level.text = str("Level ", info.level)

		
