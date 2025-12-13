extends Area2D
class_name Weapon

# 行为接口/子类（已实现）
# ===================== 核心属性 =====================
## 武器配置（外部传入，必选）
@export var config: WeaponConfig = null
## 存活状态（控制行为执行）
var is_alive: bool = true
## 目标位置（移动行为的朝向目标）
var target: Vector2 = Vector2.ZERO
## 移动方向向量（兼容原有逻辑）
var angle: Vector2 = Vector2.ZERO
## 行为组件字典（管理所有维度的行为）
var behaviors: Dictionary = {
	"move": null,       # 移动行为（IMoveBehavior）
	"hit": null,        # 命中行为（IHitBehavior）
	"lifetime": null,   # 生命周期行为（ILifetimeBehavior）
	"vfx": null,        # 视觉音效行为（IVFXBehavior，可选）
	"target": null      # 目标检测行为（ITargetBehavior，可选）
}

# ===================== 核心信号（解耦外部逻辑） =====================
## 武器命中目标时触发
## @param weapon: 当前武器实例
## @param damage: 伤害值
## @param knockback: 击退值
## @param target: 命中的目标节点
signal hit(weapon: Weapon, damage: int, knockback: float, target: Node2D)
## 武器销毁时触发
signal destroyed(weapon: Weapon)
## 武器需要从外部列表移除时触发（兼容原有逻辑）
signal remove_object_from_list(object: Weapon)

# ===================== 生命周期 =====================
func _ready() -> void:
	# 1. 基础校验（配置不能为空）
	if not config:
		push_error("Weapon: 未配置WeaponConfig！")
		queue_free()
		return
	
	# 2. 初始化核心状态
	is_alive = true
	
	# 3. 初始化行为组件（核心）
	_init_behaviors()
	
	# 4. 绑定碰撞信号（命中检测）
	if has_node("CollisionShape2D"):
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# 仅存活武器执行逻辑
	if not is_alive:
		return
	
	# 1. 调度移动行为（物理帧核心）
	if behaviors["move"]:
		behaviors["move"].update_movement(self, delta)
	
	# 2. 调度目标检测行为（近战/跟踪武器专用）
	if behaviors["target"]:
		behaviors["target"].update_target_detection(self, delta)

func _process(delta: float) -> void:
	# 仅存活武器执行逻辑
	if not is_alive:
		return
	
	# 调度生命周期检测（普通帧即可，无需物理帧）
	if behaviors["lifetime"]:
		behaviors["lifetime"].check_lifetime_status(self, delta)

# ===================== 核心方法 =====================
## 初始化所有行为组件（核心逻辑）
func _init_behaviors() -> void:
	# -------------------------- 1. 初始化移动行为（必选） --------------------------
	match config.move_behavior_type:
		WeaponConfig.MoveBehaviorType.LINEAR:
			behaviors["move"] = LinearMoveBehavior.new()
		WeaponConfig.MoveBehaviorType.TRACKING:
			# 后续实现 TrackingMoveBehavior 后替换
			behaviors["move"] = LinearMoveBehavior.new() # 临时占位
		WeaponConfig.MoveBehaviorType.STATIC:
			# 后续实现 StaticMoveBehavior 后替换
			behaviors["move"] = LinearMoveBehavior.new() # 临时占位
		WeaponConfig.MoveBehaviorType.BOUNCE:
			# 后续实现 BounceMoveBehavior 后替换
			behaviors["move"] = LinearMoveBehavior.new() # 临时占位
	# 初始化移动参数
	if behaviors["move"]:
		behaviors["move"].init_move_params(self)

	# -------------------------- 2. 初始化命中行为（必选） --------------------------
	match config.hit_behavior_type:
		WeaponConfig.HitBehaviorType.SINGLE:
			behaviors["hit"] = SingleHitBehavior.new()
		WeaponConfig.HitBehaviorType.AREA:
			# 后续实现 AreaHitBehavior 后替换
			behaviors["hit"] = SingleHitBehavior.new() # 临时占位
		WeaponConfig.HitBehaviorType.CONTINUOUS:
			# 后续实现 ContinuousHitBehavior 后替换
			behaviors["hit"] = SingleHitBehavior.new() # 临时占位
	# 初始化命中参数
	if behaviors["hit"]:
		behaviors["hit"].init_hit_params(self)

	# -------------------------- 3. 初始化生命周期行为（必选） --------------------------
	behaviors["lifetime"] = DefaultLifetimeBehavior.new()
	if behaviors["lifetime"]:
		behaviors["lifetime"].init_lifetime(self)

	# -------------------------- 4. 初始化VFX行为（可选） --------------------------
	if config.spawn_vfx_path != "" or config.hit_vfx_path != "" or config.destroy_vfx_path != "":
		behaviors["vfx"] = DefaultVFXBehavior.new()
		if behaviors["vfx"]:
			behaviors["vfx"].init_vfx_resources(self)
			# 播放生成特效
			behaviors["vfx"].play_spawn_vfx(self)

	# -------------------------- 5. 初始化目标检测行为（可选） --------------------------
	if config.weapon_type == WeaponConfig.WeaponType.MELEE:
		behaviors["target"] = MeleeDetectBehavior.new()
		if behaviors["target"]:
			behaviors["target"].init_target_detection(self)

## 承受伤害（扣耐久，耐久耗尽则销毁）
## @param charge: 扣血基数（默认1）
func take_damage(charge: int = 1) -> void:
	if not is_alive:
		return
	
	# 1. 扣耐久
	config.hp -= charge
	
	# 2. 耐久耗尽则销毁
	if config.hp <= 0:
		remove_object_from_list.emit(self) # 兼容原有信号
		destroy()

## 销毁武器（统一清理逻辑）
func destroy() -> void:
	if not is_alive:
		return
	
	# 1. 标记为死亡
	is_alive = false
	
	# 2. 清理所有行为组件
	if behaviors["move"]:
		behaviors["move"].cleanup_movement(self)
	if behaviors["hit"]:
		behaviors["hit"].cleanup_hit(self)
	if behaviors["lifetime"]:
		behaviors["lifetime"].cleanup_lifetime(self)
	if behaviors["vfx"]:
		behaviors["vfx"].play_destroy_vfx(self)
		behaviors["vfx"].cleanup_vfx(self)
	if behaviors["target"]:
		behaviors["target"].cleanup_target_detection(self)

	# 3. 触发销毁信号
	destroyed.emit(self)
	
	# 4. 延迟销毁（保证特效播放完成，可选）
	await get_tree().create_timer(0.1).timeout
	queue_free()

# ===================== 碰撞/事件回调 =====================
## 碰撞到物体时触发（命中检测）
func _on_body_entered(body: Node2D) -> void:
# 加固：仅检测存活状态 + 有命中行为 + 目标是敌人
	if not is_alive or not behaviors["hit"] or not is_instance_valid(body) or not body.is_in_group("enemy"):
		print("碰撞过滤：非敌人目标/武器已死亡，跳过命中逻辑")
		return
	
	print("检测到有效碰撞：", body.name)
	# 触发命中行为逻辑
	behaviors["hit"].process_hit(self, body)
	
	# 播放命中VFX
	if behaviors["vfx"]:
		behaviors["vfx"].play_hit_vfx(self, body)

## 屏幕外销毁（兼容原有逻辑，由VisibleOnScreenNotifier2D触发）
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if is_alive:
		destroy()

# ===================== 工具方法（核心修改点） =====================
## 安全读取武器配置参数
## @param config_dict_name: 配置字典名（move_config/hit_config）
## @param config_key: 参数名
## @param default_val: 默认值
func _get_weapon_param(config_dict_name: String, config_key: String, default_val: Variant) -> Variant:
	if not config:
		return default_val
	
	# 修正点1：Godot Resource.get()仅接受1个参数，先判断属性是否存在
	var config_dict: Dictionary = {}
	if config.has(config_dict_name): # 检查属性是否存在
		config_dict = config.get(config_dict_name) # 仅传1个参数
	else:
		config_dict = {} # 属性不存在则返回空字典
	
	# 修正点2：字典的get()可传默认值（这是合法的，因为是Dictionary类型）
	return config_dict.get(config_key, default_val)
