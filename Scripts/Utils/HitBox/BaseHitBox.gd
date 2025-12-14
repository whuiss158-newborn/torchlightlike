extends Area2D
class_name BaseHitBox

# 通用攻击参数（子类直接复用，无需重声明）
@export var attack_damage: int = 1
@export var attack_knockback: float = 50.0
@export var target_hurtbox_group: String = "hurt_box_enemy"  # 父类定义，子类直接赋值
@export var host: Node = null  # 父类定义，子类绑定后校验类型

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	add_to_group("hit_box")
	monitoring = true
	monitorable = true
	
	# 可选：校验host是否绑定（避免空值）
	if not is_instance_valid(host):
		push_warning("%s 未绑定host！请在编辑器中设置" % name)

# 通用碰撞检测
func _on_area_entered(area: Area2D) -> void:
	if not _is_host_alive() or not area.is_in_group(target_hurtbox_group) or not is_instance_valid(area):
		return
	_trigger_attack(area)

# 通用攻击触发逻辑
func _trigger_attack(hurt_box: Area2D) -> void:
	var final_damage = _get_final_damage()
	var final_knockback = _get_final_knockback()
	print("trigger attack", final_damage, final_knockback)
	var hit_pos = global_position
	
	if hurt_box.has_signal("take_damage"):
		hurt_box.take_damage.emit(final_damage, hit_pos, final_knockback)
	
	if host and host.has_method("_on_hitbox_attack"):
		host._on_hitbox_attack(hurt_box.get_parent(), final_damage, hit_pos)

# 父类基础函数（子类直接重写，无override）
func _is_host_alive() -> bool:
	return is_instance_valid(host)

func _get_final_damage() -> int:
	return attack_damage

func _get_final_knockback() -> float:
	return attack_knockback
