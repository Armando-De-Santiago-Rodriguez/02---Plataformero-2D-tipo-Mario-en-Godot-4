extends CharacterBody2D

## --- SEÑAL DE MUERTE ---
# Esta señal le avisará a la escena Main cuando el jugador muera.
signal player_died

# --- VARIABLES DE MOVIMIENTO ---
@export var speed = 100.0
@export var run_speed_multiplier = 2
@export var jump_velocity = -350.0
@export var jump_cooldown = 0.5
@export var Death_sound: AudioStream
@export var Jump_sound: AudioStream

## --- VARIABLES DE VIDA ---
@export var max_health: int = 10
var current_health: int
@export var death_y_position: float = 750.0 ## NUEVO: Coordenada Y para morir.
var is_dead: bool = false ## NUEVO: Para evitar muertes múltiples.

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	$JumpCooldownTimer.wait_time = jump_cooldown
	## Inicializamos la vida del jugador al empezar.
	current_health = max_health
	GameEvents.health_updated.emit.call_deferred(current_health, max_health)


func _physics_process(delta):
	# Si estamos muertos, no procesamos nada.
	if is_dead:
		return
		
	# --- 1. Gravedad ---
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- 2. Salto y Cooldown ---
	if Input.is_action_just_pressed("jump") and is_on_floor() and $JumpCooldownTimer.is_stopped():
		velocity.y = jump_velocity
		$JumpCooldownTimer.start()
		if $Jump_sound and $Jump_sound.stream: # Una forma un poco más limpia de comprobar
			$Jump_sound.play()

	# --- 3. Movimiento Horizontal (Caminar y Correr) ---
	var direction = Input.get_axis(&"left", &"right")
	var is_running = Input.is_action_pressed(&"run")
	var current_speed = speed
	
	if is_running:
		current_speed = speed * run_speed_multiplier
	
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	# --- 4. Lógica de Animación ---
	update_animation()

	# --- 5. Mover el personaje ---
	move_and_slide()
	
	# --- 6. NUEVO: Comprobar si el jugador cae al vacío ---
	if global_position.y > death_y_position:
		die()


func update_animation():
	if not is_on_floor():
		$AnimatedSprite2D.play(&"jump")
	else:
		if velocity.x != 0:
			if Input.is_action_pressed(&"run"):
				$AnimatedSprite2D.play(&"run")
			else:
				$AnimatedSprite2D.play(&"walk")
		else:
			$AnimatedSprite2D.play(&"idle")

	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true


## --- FUNCIONES DE COMBATE ---

# Esta es la función que los enemigos llamarán para hacerte daño.
func take_damage(amount: int):
	if is_dead:
		return

	current_health -= amount
	print("¡Jugador herido! Vida restante: ", current_health)
	# --- NUEVA LÍNEA ---
	# Avisamos al HUD del cambio de vida.
	GameEvents.emit_signal("health_updated", current_health, max_health)

	# Creamos un efecto de "flash" rojo para dar feedback visual.
	var tween = create_tween()
	$AnimatedSprite2D.modulate = Color(1, 0.5, 0.5)
	tween.tween_property($AnimatedSprite2D, "modulate", Color(1, 1, 1), 0.2)

	if current_health <= 0:
		die()

# Esta función se ejecuta cuando la vida llega a 0 o se cae al vacío.
func die():
	# Si ya estamos muertos, no hacer nada más.
	if is_dead:
		return
	is_dead = true # ¡Importante! Marcamos como muerto para evitar llamadas múltiples.
	
	print("El jugador ha muerto.")
	player_died.emit()
	set_physics_process(false) # Detenemos el movimiento

	# Comprobamos si la animación de muerte existe
	if $AnimatedSprite2D.sprite_frames.has_animation(&"death"):
		$AnimatedSprite2D.flip_h = velocity.x < 0
		$AnimatedSprite2D.play(&"death")
		if has_node("Death_sound") and $Death_sound:
			$Death_sound.play()
	else:
		# Si no hay animación de muerte, simplemente ocultamos al jugador.
		hide()
