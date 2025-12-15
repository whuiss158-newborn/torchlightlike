class_name EnemyData extends Resource

enum EnemyType {
	MELEE,
	RANGED,
	BOSS
}

enum EnemyRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

@export var enemy_type: EnemyType = EnemyType.MELEE
@export var rarity: EnemyRarity = EnemyRarity.COMMON
@export var display_name: String = "Enemy"
@export var description: String = "A generic enemy"

# 基础属性
@export var max_health: int = 10
@export var move_speed: float = 20.0
@export var attack_damage: int = 2
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0
@export var knockback_recovery: float = 3.5
@export var exp_drop: int = 5

# 视觉与音效
@export var sprite_texture: Texture2D = null
@export var hit_sound: AudioStream = null
@export var death_sound: AudioStream = null
@export var death_effect: PackedScene = null

# 动画相关属性
@export var animation_sprite_sheet: Texture2D = null
@export var animation_frames: Dictionary = {
	"idle": {"frames": [0], "speed": 1.0},
	"move": {"frames": [0, 1], "speed": 2.0},
	"attack": {"frames": [2, 3], "speed": 3.0},
	"hurt": {"frames": [4], "speed": 1.0},
	"death": {"frames": [5, 6], "speed": 2.0}
}
@export var frame_size: Vector2 = Vector2(32, 32)
