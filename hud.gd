extends CanvasLayer

# --- NUEVA LÍNEA ---
# Obtenemos una referencia a nuestra barra de vida.
@onready var health_bar = $HealthBar
@onready var game_over_screen = $GameOverScreen
@onready var you_win_screen = $YouWinScreen

func _ready():
	GameEvents.score_updated.connect(_on_score_updated)
	GameEvents.health_updated.connect(_on_health_updated)

func _on_score_updated(new_score):
	$ScoreLabel.text = "Score: " + str(new_score)

# --- NUEVA FUNCIÓN ---
# Esta función se ejecutará cada vez que la vida del jugador cambie.
func _on_health_updated(current_health, max_health):
	# Actualizamos los valores de la barra de progreso.
	health_bar.max_value = max_health
	health_bar.value = current_health
	
func show_game_over():
	game_over_screen.show()
	
func show_you_win():
	you_win_screen.show()
