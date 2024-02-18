@tool
extends Node2D

var angle:= 0.0

@export var ring:RingTiltable
@export_range(0.0, 1.0) var planet_tilt := 1.0 : 
	set(value):
		planet_tilt = value
		set_tilts()

@onready var sprite = $PlanetSprite
@onready var marker = $PlanetSprite/LightSource
@onready var icon = $PlanetSprite/LightSource/Icon

var light_direction := Vector3.ONE

var time := 0.0


func _process(delta):
	time -= delta*0.25
	#angle -= delta * 0.25
	#marker.position = Vector2.RIGHT.rotated(angle) * 2.5
	icon.z_index = sign(marker.position.y) * 2
	planet_tilt = sin(time) *0.8
	light_direction = Vector3(marker.position.x, marker.position.y, marker.position.y).normalized()
	var matrix = Basis(Vector3.UP, time) * Basis(Vector3.RIGHT, planet_tilt * PI * 0.5)
	sprite.material.set_shader_parameter("light_direction", light_direction)
	sprite.material.set_shader_parameter("planet_matrix", matrix)
	if ring:
		ring.update(light_direction)
		
	set_tilts()
	
func set_tilts():
	if sprite:
		sprite.material.set_shader_parameter("planet_tilt", planet_tilt)
		sprite.material.set_shader_parameter("rings_inner_radius", ring.radius_inner)
		sprite.material.set_shader_parameter("rings_outer_radius", ring.radius_outer)
	if ring:
		ring.tilt = planet_tilt
