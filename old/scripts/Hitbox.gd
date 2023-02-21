class_name Hitbox_temp
extends Area2D

var parent = get_parent()

export var light_damage := 10
#onready var parentState = get_parent().selfState
var player_list = [] 
#onready var Hitbox_id = owner.Skin_id

#	player_list.append(parent)
#	player_list.append(self)

#func _init() -> void:
#	collision_layer = 2
#	collision_mask = 0
