extends Area2D
class_name Killbox

#var id: = 666

func _init() -> void:
	set_collision_layer(16)
	set_collision_mask(0)

func _ready():
	pass
