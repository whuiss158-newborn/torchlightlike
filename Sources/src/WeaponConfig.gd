extends Resource
class_name WeaponConfig  # 全局类名，方便其他脚本引用

# ===================== 核心枚举定义（武器/行为类型） =====================
# 武器类型枚举（后续扩展新武器只需加枚举值）
enum WeaponType {
	BULLET,       # 普通弹道武器（直线飞行）
	TRACKING,     # 跟踪武器（追踪目标）
	EXPLOSIVE,    # 爆炸武器（范围伤害）
	MELEE         # 近战武器（原地/短程攻击）
}

# 移动行为类型枚举（不同移动逻辑的标识）
enum MoveBehaviorType {
	LINEAR,       # 直线移动
	TRACKING,     # 跟踪移动
	STATIC,       # 静止（近战/炮台类）
	BOUNCE        # 弹跳移动（预留扩展）
}

# 命中行为类型枚举（不同命中逻辑的标识）
enum HitBehaviorType {
	SINGLE,       # 单体命中（仅击中第一个目标）
	AREA,         # 范围命中（爆炸/近战）
	CONTINUOUS    # 持续命中（激光类，预留扩展）
}

# ===================== 基础属性（所有武器通用） =====================
# 武器类型（编辑器下拉选择）
@export var weapon_type: WeaponType = WeaponType.BULLET
# 初始耐久（可被击落的武器，如子弹；近战/激光可设为1）
@export var hp: int = 2
# 基础移动速度（静止武器设为0）
@export var speed: float = 100.0
# 基础伤害值
@export var damage: int = 5
# 击退力度
@export var knockback: float = 100.0
# 碰撞/视觉尺寸缩放（1.0为原始尺寸）
@export var attack_size: float = 1.0
# 生命周期（秒，超时自动销毁，防止内存泄漏）
@export var lifetime: float = 5.0
# 旋转偏移角度（适配原有武器逻辑的135度偏移）
@export var rotation_offset: float = 135.0

# ===================== 移动行为配置（按类型差异化） =====================
# 移动行为类型（编辑器下拉选择）
@export var move_behavior_type: MoveBehaviorType = MoveBehaviorType.LINEAR
# 移动行为参数（字典形式，适配不同移动类型的参数）
@export var move_config: Dictionary = {
	"track_speed": 200.0,    # 跟踪武器专属：转向速度
	"melee_range": 50.0,     # 近战武器专属：攻击范围
	"bounce_count": 3        # 弹跳武器专属：弹跳次数（预留）
}

# ===================== 命中行为配置（按类型差异化） =====================
# 命中行为类型（编辑器下拉选择）
@export var hit_behavior_type: HitBehaviorType = HitBehaviorType.SINGLE
# 命中行为参数（字典形式，适配不同命中类型的参数）
@export var hit_config: Dictionary = {
	"explosion_radius": 200.0,  # 爆炸武器专属：爆炸范围
	"charge": 1,                 # 受击扣血基数（如霰弹枪每颗弹丸扣1）
	"continuous_dps": 10.0       # 持续命中专属：每秒伤害（预留）
}

# ===================== 特效配置（预留，可视化扩展） =====================
# 生成特效路径（如子弹发射特效）
@export var spawn_vfx_path: String = ""
# 命中特效路径（如爆炸/击中火花）
@export var hit_vfx_path: String = ""
# 销毁特效路径（如子弹消失特效）
@export var destroy_vfx_path: String = ""
