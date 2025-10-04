extends Node

@onready var player = $Player
@onready var hud = $HUD
var score = 0

func _ready():
	# Conectamos las señales.
	$MusicPlayer.play()
	GameEvents.coin_collected.connect(_on_coin_collected)
	player.player_died.connect(_on_player_died)
	GameEvents.player_won.connect(_on_player_won)
	# Le decimos al HUD que muestre el puntaje inicial (0) tan pronto como el juego comience.
	GameEvents.emit_signal("score_updated", score)
	
func _on_coin_collected():
	# Cada moneda vale 1 punto (o los que quieras).
	score += 1
	
	# Emitimos la señal para que el HUD la reciba.
	GameEvents.emit_signal("score_updated", score)
	print("Puntuación actual: ", score)
	
func _on_player_died():
	print("Main se ha enterado de que el jugador ha muerto. Deteniendo enemigos.")
	$MusicPlayer.stop()
	get_tree().call_group("enemies", "stop_actions")
	hud.show_game_over()
	$GameOverTimer.start()

func _on_player_won():
	print("Main se ha enterado de que el jugador ha ganado.")
	$MusicPlayer.stop()
	get_tree().call_group("enemies", "stop_actions")
	hud.show_you_win()
	$GameOverTimer.start()
	
func _on_game_over_timer_timeout():
	get_tree().change_scene_to_file("res://mainmenu.tscn")
