extends RefCounted
class_name IVFXBehavior

# ===================== 核心抽象方法（VFX/SFX专属） =====================
## 初始化特效资源（预加载特效/音效）
## @param weapon: 所属武器实例
func init_vfx_resources(weapon: Weapon) -> void:
	push_error("IVFXBehavior: 子类必须实现 init_vfx_resources 方法！")

## 播放生成特效/音效
## @param weapon: 所属武器实例
func play_spawn_vfx(weapon: Weapon) -> void:
	push_error("IVFXBehavior: 子类必须实现 play_spawn_vfx 方法！")

## 播放命中特效/音效
## @param weapon: 所属武器实例
## @param target: 命中的目标节点
func play_hit_vfx(weapon: Weapon, target: Node2D) -> void:
	push_error("IVFXBehavior: 子类必须实现 play_hit_vfx 方法！")

## 播放销毁特效/音效
## @param weapon: 所属武器实例
func play_destroy_vfx(weapon: Weapon) -> void:
	push_error("IVFXBehavior: 子类必须实现 play_destroy_vfx 方法！")

## 清理特效资源（停止音效、销毁临时特效节点）
## @param weapon: 所属武器实例
func cleanup_vfx(weapon: Weapon) -> void:
	push_error("IVFXBehavior: 子类必须实现 cleanup_vfx 方法！")
