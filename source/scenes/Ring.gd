@tool
extends Sprite2D

@export_range(1.0,1000.0) var radius_outer = 2.32
@export_range(1.0,1000.0) var radius_inner = 1.239

func _ready():
	scale = Vector2.ONE * radius_outer
	material.set_shader_parameter("rim_distance", radius_inner/radius_outer)
	material.set_shader_parameter("shadow_width", 0.85/radius_outer/radius_inner)

