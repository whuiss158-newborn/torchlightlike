extends CharacterBody2D


# ===================== 基础属性 =====================
var speed = 40
var attack_speed_growth = 1.3
# 武器相关扩展属性（关联新武器系统）
var weapon_damage_bonus = 0  # 武器伤害加成（由升级卡牌提供）
var weapon_speed_bonus = 1.0 # 武器移动速度加成（默认1倍）

@onready var sprite = $Sprite2D
@onready var attack_cool_down_timer: Timer = $Attack/AttackCoolDownTimer
@onready var experience_bar: TextureProgressBar = %ExperienceBar
@onready var lbl_level: Label = %lbl_level
@onready var level_up_panel: Panel = %LevelUpPanel
@onready var card_container: Control = level_up_panel.get_node("container_card")
@onready var exp_detection_area: Area2D = $ExpDetectionArea

# 武器系统
@export var weapon_prefab: PackedScene = null # 编辑器绑定新武器预制体
#@export var weapon_config: WeaponConfig = null # 编辑器绑定武器配置
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
	
	# 新武器系统：校验配置
	if not weapon_prefab:
		push_warning("玩家未绑定武器预制体！请在编辑器中设置")

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

# ===================== 武器回调（扩展） =====================
# 武器命中目标时的额外处理（比如吸血、暴击等）
func _on_weapon_hit(weapon: Weapon, damage: int, knockback: float, target: Node2D) -> void:
	print("玩家武器命中：", target.name, " 最终伤害：", damage)
	# 示例：升级卡牌的暴击效果（可扩展）
	# if randf() < 0.1: # 10%暴击率
	# 	target.take_damage(damage * 2)
# 武器销毁时的清理（可选）
func _on_weapon_destroyed(weapon: Weapon) -> void:
	pass # 可添加武器销毁特效、计数等逻辑

func get_random_target():
	# 过滤无效敌人
	var valid_enemies = enemy_close.filter(is_instance_valid)
	if valid_enemies.size() == 0:
		return null
	return valid_enemies.pick_random()
	
func get_closest_enemy() -> CharacterBody2D:
	var valid_enemies = enemy_close.filter(is_instance_valid)
	if valid_enemies.size() == 0:
		return null
	# 按距离排序，返回最近的
	valid_enemies.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	return valid_enemies[0]
	
func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("enemy") and not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and enemy_close.has(body):
		enemy_close.erase(body)


func _on_hurt_box_take_damage(damage: int) -> void:
	print("player get damage", damage)


func _on_exp_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot") and area.has_method("collect"):
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
	GameManager._reset_used_card_types()

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
			# 原逻辑：GameManager攻击加成 → 改为武器伤害加成
			weapon_damage_bonus += card_data.attack_power
			# GameManager.player_attack_bonus += card_data.attack_power # 可保留，兼容其他逻辑
			print("武器攻击力增加: ", card_data.attack_power, " 总加成：", weapon_damage_bonus)
		CardData.CardType.SPEED:
			# 原逻辑：移动速度加成 + 新增武器速度加成
			speed += card_data.move_speed_bonus * speed
			weapon_speed_bonus += card_data.move_speed_bonus * 0.2 # 武器速度加成（20%的移动加成比例）
			print("移动速度增加，武器速度加成：", weapon_speed_bonus)
		CardData.CardType.EXPERIENCE:
			exp_detection_area.scale += exp_detection_area.scale * card_data.pickup_range_bonus
			print("经验拾取范围增加")
		# 扩展：新增武器专属卡牌类型（比如暴击、范围伤害）
		# CardData.CardType.WEAPON_RANGE:
		# 	weapon_config.attack_size *= 1.2 # 武器攻击范围扩大
		# 	print("武器攻击范围增加")
		
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

func _on_attack_cool_down_timer_timeout() -> void:
	if enemy_close.size() == 0 or not weapon_prefab:
		return
	
	# 1. 获取随机敌人目标
	var target_enemy = get_closest_enemy()
	if not is_instance_valid(target_enemy):
		return
	
	# 2. 实例化新武器（替代旧iceSpear）
	var weapon_instance = weapon_prefab.instantiate() as Weapon
	if not weapon_instance:
		push_error("武器实例化失败！请检查预制体是否挂载Weapon.gd")
		return
	
	# 3. 配置武器核心参数（结合玩家升级加成）
	# 克隆TestBullet的原始配置（关键：避免修改原资源）
	var weapon_config_copy = weapon_instance.config.duplicate() as WeaponConfig
	# 应用升级加成：伤害/速度
	weapon_config_copy.damage += weapon_damage_bonus
	weapon_config_copy.speed *= weapon_speed_bonus
	# 将副本赋值给武器实例（覆盖原config）
	weapon_instance.config = weapon_config_copy
	weapon_instance.target = target_enemy.global_position # 攻击目标
	weapon_instance.global_position = global_position # 生成位置（玩家位置）
	
	# 4. 挂载武器到场景（而非玩家子节点，避免跟随移动）
	get_tree().current_scene.add_child(weapon_instance)
	
	# 5. 监听武器命中信号（可选：玩家层面处理额外效果）
	weapon_instance.hit.connect(_on_weapon_hit)
	weapon_instance.destroyed.connect(_on_weapon_destroyed)
