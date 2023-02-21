class_name Hitbox_TM
extends Area2D

var parent = get_parent()

export var light_damage := 10
#onready var parentState = get_parent().selfState
var player_list = [] 

func _ready():
	player_list.append(parent)
	player_list.append(self)
