extends Area2D

func _on_body_entered(body):
	# Comprobamos si el cuerpo que entró es el jugador.
	if body.is_in_group("player"):
		print("El jugador ha llegado a la meta!")
		# Emitimos una señal global para que el juego se entere.
		GameEvents.emit_signal("player_won")

		# Desactivamos la colisión para no ganar múltiples veces.
		$CollisionShape2D.set_deferred("disabled", true)
