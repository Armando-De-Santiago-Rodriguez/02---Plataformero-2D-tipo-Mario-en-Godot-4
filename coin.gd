extends Area2D

func collect():
	# Desactivamos la colisión para no ser recogidos dos veces.
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Ocultamos la moneda para que parezca que desaparece al instante.
	$AnimatedSprite2D.hide()

	# Reproducimos el sonido.
	$PickupSound.play()

	# Le avisamos al juego que una moneda fue recolectada.
	# Usaremos un "Signal Bus" global para esto (lo creamos en el siguiente paso).
	GameEvents.emit_signal("coin_collected")

	# Esperamos a que el sonido termine de reproducirse antes de destruir la moneda.
	await $PickupSound.finished
	queue_free()

func _on_body_entered(body):
	print("Un cuerpo entró en el área de la moneda. Nombre del cuerpo: ", body.name)
	# Si el cuerpo que entró en el área está en el grupo "player"...
	if body.is_in_group("player"):
		print("El cuerpo es el jugador! Intentando recolectar...")
		collect() # ...llamamos a nuestra función para ser recolectada.
