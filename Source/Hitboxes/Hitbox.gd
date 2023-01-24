extends Area2D
class_name Hitbox

export var dmg: = 300.0
export var light_attack_dmg: = 300.0
export var heavy_attack_dmg: = 1000.0

func _init():
	collision_layer = 4
	collision_mask = 0
