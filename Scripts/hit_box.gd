extends Node

@export var damage: int = 1
@onready var disable_timer: Timer = $DisableTimer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func disableNow():
	collision_shape_2d.set_deferred("disabled", true)
	disable_timer.start()


func _on_disable_timer_timeout() -> void:
	collision_shape_2d.set_deferred("disabled", false) # Replace with function body.
