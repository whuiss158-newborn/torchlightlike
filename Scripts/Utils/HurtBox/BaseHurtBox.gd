extends Area2D
class_name BaseHurtBox

# ===================== 通用受击规则（兼容你现有逻辑） =====================
@export_enum("Cooldown", "HitOnce", "Disabled") var hurt_box_type: int = 0
@export var cooldown_time: float = 0.5  # 冷却时间（Cooldown类型）
# 受击缓存（HitOnce类型）
var hitted_hitboxes: Array[Area2D] = []
# 关联所属宿主（Enemy/Player）
@export var host: Node = null

# ===================== 通用逻辑 =====================
@onready var disable_timer: Timer = $DisableTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
# 通用受击信号（核心，传递标准化参数）
signal take_damage(damage: int, hit_position: Vector2, knockback: float)

func _ready() -> void:
	# 初始化定时器
	disable_timer.wait_time = cooldown_time
	disable_timer.one_shot = true
	disable_timer.timeout.connect(_on_cooldown_timeout)
	# 绑定信号（兼容你现有逻辑）
	take_damage.connect(_on_take_damage)

# 通用受击处理（兼容你现有HurtBoxType逻辑）
func _on_take_damage(damage: int, hit_position: Vector2, knockback: float) -> void:
	# 过滤无效攻击
	if damage <= 0 or not is_instance_valid(host):
		return
	
	# 处理不同受击类型
	match hurt_box_type:
		0: # Cooldown：禁用碰撞+启动冷却
			_toggle_collision(false)
			disable_timer.start()
		1: # HitOnce：避免重复受击
			if hitted_hitboxes.has(get_colliding_hitbox()):
				return
			hitted_hitboxes.append(get_colliding_hitbox())
		2: # Disabled：禁用攻击源
			var attack_source = get_colliding_hitbox()
			if attack_source and attack_source.has_method("disable_now"):
				attack_source.disable_now()
	
	# 通知宿主受击（核心：Enemy/Player各自处理掉血）
	if host.has_method("_on_hurtbox_take_damage"):
		host._on_hurtbox_take_damage(damage, hit_position, knockback)

# ===================== 通用工具方法 =====================
# 切换碰撞启用状态
func _toggle_collision(enabled: bool) -> void:
	collision_shape.set_deferred("disabled", not enabled)

# 冷却超时恢复碰撞
func _on_cooldown_timeout() -> void:
	_toggle_collision(true)

# 获取碰撞的HitBox（兼容你现有逻辑）
func get_colliding_hitbox() -> Area2D:
	for area in get_overlapping_areas():
		if area.is_in_group("hit_box"):
			return area
	return null

# 清理重复受击缓存（兼容你现有remove_item_from_hit_arr）
func remove_item_from_hit_arr(hitbox: Area2D) -> void:
	if hitted_hitboxes.has(hitbox):
		hitted_hitboxes.erase(hitbox)
