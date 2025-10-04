extends CharacterBody2D

# --- STATS BASE ---
@export var speed: float = 50.0
@export var damage: int = 1
@export var attack_cooldown: float = 1 # Tiempo en segundos entre ataques
@export var attack_sound: AudioStream

# --- ESTADO DEL ENEMIGO ---
var player = null
var is_player_in_detection_range = false
var is_player_in_attack_range = false
var can_deal_damage = true # Renombramos la variable para que sea más clara
var can_attack = true
var is_attacking = false

# --- FÍSICA ---
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	$AttackCooldownTimer.wait_time = attack_cooldown
	$AttackCooldownTimer.timeout.connect(_on_attack_cooldown_timer_timeout)

func _physics_process(delta):
	# 1. APLICAR GRAVEDAD
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. LÓGICA DE MOVIMIENTO Y ATAQUE
	if is_player_in_attack_range:
		# Si el jugador está cerca, nos detenemos para atacar.
		velocity.x = 0
		# Intentamos hacer daño solo si el cooldown ha terminado.
		if can_deal_damage:
			deal_damage_to_player()
	elif is_player_in_detection_range and player:
		# Si no, pero está en rango de detección, lo perseguimos.
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
	else:
		# Si no, frenamos.
		velocity.x = move_toward(velocity.x, 0, speed)

	# 3. ACTUALIZAR ANIMACIONES
	update_animation()

	# 4. MOVER EL PERSONAJE
	move_and_slide()


func update_animation():
	# Primero, volteamos el sprite si es necesario.
	# Solo cambiamos de dirección si no estamos en medio de un ataque.
	if not is_player_in_attack_range:
		if velocity.x > 0:
			$AnimatedSprite2D.flip_h = false
		elif velocity.x < 0:
			$AnimatedSprite2D.flip_h = true

	# Ahora, elegimos la animación correcta.
	# Para evitar que la animación se reinicie en cada frame, comprobamos si ya se está reproduciendo.
	if is_player_in_attack_range:
		if $AnimatedSprite2D.animation != "Attack":
			$AnimatedSprite2D.play("Attack")
			
			
	elif abs(velocity.x) > 0:
		if $AnimatedSprite2D.animation != "Run":
			$AnimatedSprite2D.play("Run")
	else:
		if $AnimatedSprite2D.animation != "Idle":
			$AnimatedSprite2D.play("Idle")


# --- FUNCIONES DE COMBATE ---

func deal_damage_to_player():
	# Esta función ahora solo se encarga de aplicar el daño y activar el cooldown.
	$AttackSound.play()
	can_deal_damage = false
	$AttackCooldownTimer.start()
	
	if player and player.has_method("take_damage"):
		player.take_damage(damage)
		print("Enemigo atacó al jugador. Daño: ", damage)

# --- SEÑALES DEL ÁREA DE DETECCIÓN ---

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		is_player_in_detection_range = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player = null
		is_player_in_detection_range = false
		is_player_in_attack_range = false


# --- SEÑALES DEL ÁREA DE ATAQUE ---

func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		is_player_in_attack_range = true
		# Al entrar, nos aseguramos de que el enemigo mire al jugador.
		if body.global_position.x > global_position.x:
			$AnimatedSprite2D.flip_h = false # Jugador a la derecha
		else:
			$AnimatedSprite2D.flip_h = true # Jugador a la izquierda

func _on_attack_area_body_exited(body):
	if body.is_in_group("player"):
		is_player_in_attack_range = false


# --- SEÑAL DEL TEMPORIZADOR DE COOLDOWN ---

func _on_attack_cooldown_timer_timeout():
	can_deal_damage = true # Cuando el temporizador termina, el enemigo puede hacer daño de nuevo.
	can_attack = true


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Attack":
		is_attacking = false # Ya no estamos atacando
		# Al terminar, iniciamos el cooldown para el siguiente ataque
		$AttackCooldownTimer.start()
		
func stop_actions():
	# Detenemos toda la lógica de movimiento y ataque
	set_physics_process(false)
	# Forzamos la animación de Idle para que se queden quietos
	$AnimatedSprite2D.play("Idle")
