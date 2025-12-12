extends Resource
class_name CardData

# === 1. 基础身份 ===
@export var card_name: String = "未命名卡牌"
@export_multiline var description: String = "卡牌描述"
@export var icon: Texture2D # 卡牌图标

# === 2. 类型与稀有度（使用枚举便于管理和防止拼写错误） ===
enum CardType {ATTACK, DEFENSE, SPEED, UTILITY, HEALING, EXPERIENCE, CUSTOM}
enum Rarity {COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}

@export var type: CardType = CardType.ATTACK
@export var rarity: Rarity = Rarity.COMMON
# 如果是CUSTOM类型，可以用这个字段进一步说明
@export var custom_type_label: String = ""

# === 3. 数值属性（根据你的游戏机制调整） ===
# 注意：不是每张卡都需要所有属性，按需使用
@export var attack_power: float = 0.0    # 攻击力加成
@export var defense: float = 0.0         # 防御力/护甲
@export var move_speed_bonus: float = 0.0 # 移动速度加成（百分比或固定值）
@export var pickup_range_bonus: float = 0.0 # 经验/拾取范围加成
@export var max_health_bonus: float = 0.0  # 最大生命值加成
@export var health_regen: float = 0.0      # 生命恢复
@export var critical_chance: float = 0.0   # 暴击率
@export var cooldown_reduction: float = 0.0 # 冷却缩减
@export var luck: float = 0.0              # 幸运值（影响掉落等）

# === 4. 其他拓展属性 ===
@export var level: int = 1 # 卡牌等级（可用于升级系统）
@export var cost: int = 0 # 使用或装备此卡牌消耗的资源（如法力、金币）
@export var duration: float = -1.0 # 效果持续时间（-1表示永久）
@export var is_consumable: bool = false # 是否为一次性消耗品
@export var tags: PackedStringArray = [] # 用于分类和检索的标签（如“火焰”、“寒冰”、“被动”）
@export var custom_properties: Dictionary = {} # 万能字典，存放任何未预设的特殊属性

# ====== 核心：静态生成函数 ======
static func create_random_card_by_type(target_type: CardType, target_rarity: Rarity) -> CardData:
	var new_card := CardData.new()
	new_card.type = target_type
	new_card.rarity = target_rarity
	
	# 根据稀有度决定一个数值倍率 (可自行调整平衡)
	var rarity_multiplier := 1.0
	match target_rarity:
		Rarity.COMMON:    rarity_multiplier = 1.0
		Rarity.UNCOMMON:  rarity_multiplier = 2.0
		Rarity.RARE:      rarity_multiplier = 3.0
		Rarity.EPIC:      rarity_multiplier = 5.0
		Rarity.LEGENDARY: rarity_multiplier = 8.0
	
	# 根据卡片类型，设置固定属性和基于稀有度的随机数值
	match target_type:
		CardType.ATTACK:
			new_card.card_name = _get_random_name("长剑", target_rarity)
			new_card.attack_power = _random_scaled_value(2, 3, rarity_multiplier)
			new_card.description = _format_description("攻击力提升", new_card.attack_power, "点")
			new_card.icon = preload("res://Assets/Textures/Items/Weapons/sword.png") # 示例路径
			
		CardType.SPEED:
			new_card.card_name = _get_random_name("靴子", target_rarity)
			new_card.move_speed_bonus = _random_scaled_value(0.02, 0.03, rarity_multiplier) # 百分比提升
			new_card.description = _format_description("移动速度提升", new_card.move_speed_bonus * 100, "%")
			new_card.icon = preload("res://Assets/Textures/Items/Upgrades/boots_4_green.png")
			
		CardType.DEFENSE:
			new_card.card_name = _get_random_name("盾牌", target_rarity)
			new_card.max_health_bonus = _random_scaled_value(1, 2, rarity_multiplier)
			new_card.description = _format_description("提升最大生命值", new_card.max_health_bonus, "点")
			new_card.icon = preload("res://Assets/Textures/Items/Upgrades/chunk.png")
			
		CardType.EXPERIENCE:
			new_card.card_name = _get_random_name("洞察", target_rarity)
			new_card.pickup_range_bonus = _random_scaled_value(0.05, 0.10, rarity_multiplier)
			new_card.description = _format_description("经验值拾取范围扩大", new_card.pickup_range_bonus * 100, "%")
			new_card.icon = preload("res://Assets/Textures/Items/Upgrades/thick_new.png")
			
		CardType.HEALING:
			new_card.card_name = _get_random_name("回复", target_rarity)
			new_card.health_regen = _random_scaled_value(1, 4, rarity_multiplier)
			var regen_formatted = "%.1f" % new_card.health_regen
			new_card.description = _format_description("生命回复增加", regen_formatted, "点/秒")
			new_card.icon = preload("res://Assets/Textures/Items/Upgrades/urand_mage.png")
		# ... 可以继续添加其他 CardType 的处理逻辑
	
	return new_card

# ====== 内部辅助函数 ======
# 根据稀有度生成一个带前缀/后缀的随机名称
static func _get_random_name(base_name: String, rarity: Rarity) -> String:
	var prefix := ""
	var suffix := ""
	
	match rarity:
		Rarity.COMMON:
			prefix = "破损的"
			suffix = ""
		Rarity.UNCOMMON:
			prefix = "坚固的"
			suffix = ""
		Rarity.RARE:
			prefix = "精锐"
			suffix = "之证"
		Rarity.EPIC:
			prefix = "传奇"
			suffix = "之力"
		Rarity.LEGENDARY:
			prefix = "不朽"
			suffix = "神物"
	
	# 简单的随机组合，你可以让这部分更丰富
	var name_variants = ["", "·改", "·极"]
	var variant = name_variants[randi() % name_variants.size()]
	
	return prefix + base_name + suffix

# 生成一个基础随机值，并应用稀有度倍率
static func _random_scaled_value(min_val: float, max_val: float, multiplier: float) -> float:
	var base_value = randf_range(min_val, max_val)
	return snapped(base_value * multiplier, 0.01) # 保留两位小数，使数值整洁
# 新增：格式化描述文本的辅助函数
static func _format_description(base_desc: String, value, unit: String = "") -> String:
	# 处理数值格式（如果是浮点数且为整数，则显示为整数）
	var display_value
	if value is float:
		# 检查是否为整数（如5.0）
		if abs(value - int(value)) < 0.001:
			display_value = str(int(value))
		else:
			# 保留一位小数
			display_value = "%.1f" % value
	else:
		display_value = str(value)
	
	return base_desc + " " + display_value + unit
