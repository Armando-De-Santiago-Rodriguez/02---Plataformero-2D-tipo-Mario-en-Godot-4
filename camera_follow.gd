extends Camera2D

# Exportamos una variable para poder arrastrar nuestro jugador a ella
# desde el editor, sin tener que tocar más el código.
@export var target: Node2D

func _process(_delta):
	if target:
		global_position = target.global_position
