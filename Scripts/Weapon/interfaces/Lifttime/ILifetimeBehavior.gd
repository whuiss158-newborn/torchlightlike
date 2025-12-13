extends RefCounted
class_name ILifetimeBehavior

# ===================== 核心抽象方法（生命周期专属） =====================
## 初始化生命周期（启动超时定时器、绑定屏幕外检测）
## @param weapon: 所属武器实例
func init_lifetime(weapon: Weapon) -> void:
	push_error("ILifetimeBehavior: 子类必须实现 init_lifetime 方法！")

## 检测生命周期状态（超时/屏幕外）
## @param weapon: 所属武器实例
## @param delta: 帧时间增量
func check_lifetime_status(weapon: Weapon, delta: float) -> void:
	push_error("ILifetimeBehavior: 子类必须实现 check_lifetime_status 方法！")

## 清理生命周期资源（停止定时器）
## @param weapon: 所属武器实例
func cleanup_lifetime(weapon: Weapon) -> void:
	push_error("ILifetimeBehavior: 子类必须实现 cleanup_lifetime 方法！")
