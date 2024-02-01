@tool
extends Node2D

var angle:= 0.0
@onready var sprite = $PlanetSprite
@onready var marker = $PlanetSprite/LightSource

func _process(delta):
	angle += delta * 0.5
	marker.position = Vector2.RIGHT.rotated(angle) * 2.0
	var light_direction:= Vector3(marker.position.x, marker.position.y, 1.0).normalized()
	sprite.material.set_shader_parameter("light_direction", light_direction)
	
