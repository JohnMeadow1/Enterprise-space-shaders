@tool
extends Node2D
class_name RingTiltable

@export_range(0.0, 1.0) var tilt := 1.0 : 
	set(value):
		tilt = value
		set_tilt()
@export_range(1.0, 4.0) var radius_inner := 1.0 :
	set(value):
		radius_inner = value
		update_materials()
@export_range(1.0, 8.0) var radius_outer := 2.0 :
	set(value):
		radius_outer = value
		scale.x = value
		set_tilt()
		update_materials()
@onready var top = $Top
@onready var bottom = $Bottom

func _ready():
	set_tilt()
	top.material = top.material.duplicate()
	bottom.material = bottom.material.duplicate()
	update_materials()

func update(light_direction:Vector3):
	if top:
		top.material.set_shader_parameter("light_direction", light_direction)
	if top:
		bottom.material.set_shader_parameter("light_direction", light_direction)
	update_materials()

func set_tilt():
	scale.y = scale.x * tilt
	
func update_materials():
	if top:
		top.material.set_shader_parameter("rim_distance", radius_inner / radius_outer)
		top.material.set_shader_parameter("shadow_width", 0.95 / radius_outer)
		top.material.set_shader_parameter("tilt", 1.0-tilt*0.8)
	if bottom:
		bottom.material.set_shader_parameter("rim_distance", radius_inner / radius_outer)
		bottom.material.set_shader_parameter("shadow_width", 0.95 / radius_outer)
		bottom.material.set_shader_parameter("tilt", 1.0-tilt*0.8)
	
