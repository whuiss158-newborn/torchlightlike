# GameManager.gd
extends Node

# ====== 信号 ======
signal player_xp_changed(new_xp: int, xp_to_next_level: int)
signal player_level_up(new_level: int)

# ====== 玩家状态 (可序列化/保存) ======
var current_level: int = 1:
	set(value):
		current_level = value
		# 升级时，可以在这里增加一些全局效果，比如提高敌人强度

var current_xp: int = 0
var xp_to_next_level: int = 5

# ====== 新增：支持连续升级的变量 ======
var pending_level_ups: int = 0

# ====== 新增：玩家属性加成（用于卡片效果） ======
var player_attack_bonus: float = 0.0
var player_speed_bonus: float = 0.0
var player_defense_bonus: float = 0.0
var player_pickup_range_bonus: float = 0.0
var player_health_regen_bonus: float = 0.0

# ====== 卡牌生成相关配置 ======
var available_card_types_on_level_up: Array = [
	CardData.CardType.ATTACK,
	CardData.CardType.SPEED,
	CardData.CardType.DEFENSE,
	CardData.CardType.EXPERIENCE,
	CardData.CardType.HEALING
]

var card_rarity_weights: Array[int] = [50, 30, 15, 4, 1]
# ====== 新增：已使用卡牌Type缓存（核心去重变量） ======
var _used_card_types: Array = []

# ====== 节点引用 ======
@onready var card_container: Control = null

func _ready():
	pass

# ====== 核心API ======
func add_player_xp(xp_amount: int):
	current_xp += xp_amount
	player_xp_changed.emit(current_xp, xp_to_next_level)
	
	# 计算本次经验能够升多少级
	var levels_gained = 0
	while current_xp >= xp_to_next_level:
		levels_gained += 1
		current_xp -= xp_to_next_level
		xp_to_next_level = int(xp_to_next_level * 1.5)
	
	# 如果有升级，记录次数并触发第一次升级
	if levels_gained > 0:
		pending_level_ups = levels_gained
		process_next_pending_level_up()

# ====== 新增：处理下一次待办升级 ======
func process_next_pending_level_up():
	if pending_level_ups > 0:
		current_level += 1
		pending_level_ups -= 1
		player_level_up.emit(current_level)
		player_xp_changed.emit(current_xp, xp_to_next_level)

# ====== 新增：检查是否有待处理升级 ======
func has_pending_level_up() -> bool:
	return pending_level_ups > 0

# ====== 新增：生成随机卡片数据的函数（供Player调用） ======
func _generate_random_card_data() -> CardData:
	# 1. 筛选出未使用的Type（可用Type - 已用Type）
	var unused_types = []
	for type in available_card_types_on_level_up:
		if type not in _used_card_types:
			unused_types.append(type)
	
	# 2. 边界处理：如果所有Type都已使用，重置缓存（循环复用）
	if unused_types.is_empty():
		_used_card_types.clear()
		unused_types = available_card_types_on_level_up.duplicate()
	
	# 3. 从未使用的Type中随机选一个
	var random_type = unused_types.pick_random()
	# 4. 将选中的Type加入已用缓存，避免重复
	_used_card_types.append(random_type)
	print(unused_types)
	
	# 5. 生成对应Type的随机稀有度卡牌（原有逻辑不变）
	var random_rarity = _get_weighted_random_rarity(card_rarity_weights)
	return CardData.create_random_card_by_type(random_type, random_rarity)
	
func _reset_used_card_types():
	_used_card_types.clear()

func set_card_container(container_node: Control):
	if container_node is Control:
		card_container = container_node
		print("GameManager: 卡片容器已设置 -> ", container_node.name)
	else:
		push_error("GameManager: 传入的卡片容器不是Control类型节点！")

func spawn_random_card_at_position(position: Vector2):
	if not card_container:
		push_error("GameManager: 卡片容器未设置，无法生成卡片！")
		return
	
	var random_type = available_card_types_on_level_up.pick_random()
	var random_rarity = _get_weighted_random_rarity(card_rarity_weights)
	var card_data = CardData.create_random_card_by_type(random_type, random_rarity)
	
	var card_scene = preload("res://Scenes/upgrade_card_item.tscn")
	var new_card = card_scene.instantiate()
	
	new_card.card_data = card_data
	
	card_container.add_child(new_card)
	new_card.global_position = position
	
	new_card.card_clicked.connect(_on_card_clicked)
	
	print("生成卡片：%s [%s]" % [card_data.card_name, CardData.Rarity.keys()[random_rarity]])
	return new_card

func _get_weighted_random_rarity(weights: Array[int]) -> int:
	var total_weight := 0
	for w in weights: total_weight += w
	var random_point = randi() % total_weight
	var cumulative := 0
	for i in weights.size():
		cumulative += weights[i]
		if random_point < cumulative:
			return i
	return 0

func _on_card_clicked(card_node):
	print("玩家选择了卡片：", card_node.card_data.card_name)
	# 应用卡片效果到全局属性
	_apply_card_effect_global(card_node.card_data)
	card_node.queue_free()

# ====== 新增：全局应用卡片效果 ======
func _apply_card_effect_global(card_data: CardData):
	match card_data.type:
		CardData.CardType.ATTACK:
			player_attack_bonus += card_data.attack_power
			print("全局攻击力加成: ", player_attack_bonus)
		CardData.CardType.SPEED:
			player_speed_bonus += card_data.move_speed_bonus
			print("全局移动速度加成: ", player_speed_bonus)
		CardData.CardType.DEFENSE:
			player_defense_bonus += card_data.max_health_bonus
			print("全局防御加成: ", player_defense_bonus)
		CardData.CardType.EXPERIENCE:
			player_pickup_range_bonus += card_data.pickup_range_bonus
			print("全局拾取范围加成: ", player_pickup_range_bonus)
		CardData.CardType.HEALING:
			player_health_regen_bonus += card_data.health_regen
			print("全局生命恢复加成: ", player_health_regen_bonus)

# ====== 新增：获取全局加成的函数（供Player查询） ======
func get_player_bonuses() -> Dictionary:
	return {
		"attack": player_attack_bonus,
		"speed": player_speed_bonus,
		"defense": player_defense_bonus,
		"pickup_range": player_pickup_range_bonus,
		"health_regen": player_health_regen_bonus
	}

func reset_game_state():
	current_level = 1
	current_xp = 0
	xp_to_next_level = 100
	pending_level_ups = 0
	player_attack_bonus = 0.0
	player_speed_bonus = 0.0
	player_defense_bonus = 0.0
	player_pickup_range_bonus = 0.0
	player_health_regen_bonus = 0.0
	player_xp_changed.emit(current_xp, xp_to_next_level)
	print("GameManager: 游戏状态已重置")

func get_level_info() -> Dictionary:
	return {
		"level": current_level,
		"current_xp": current_xp,
		"xp_to_next_level": xp_to_next_level
	}
