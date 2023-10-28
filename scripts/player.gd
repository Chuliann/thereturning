extends CharacterBody3D


var SPEED : float = 2.8
const JUMP_VELOCITY : float = 4.5

var walking_speed : float = 2.8
var running_speed : float = 5.0

var running : bool = false

var is_locked : bool = false

@export var sens_horizontal : float = 0.5
@export var sens_vertical : float = 0.5

@onready var camera = $camera
@onready var animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var visuals = $visuals


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(event.relative.x * sens_horizontal) * -1)
		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera.rotate_x(deg_to_rad(event.relative.y * sens_vertical) * -1)
	
func _physics_process(delta):
	
	if !animation_player.is_playing():
		is_locked = false
	
	if Input.is_action_just_pressed("kick"):
		if animation_player.current_animation != 'kick':
			animation_player.play('kick')
			is_locked=true
	
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if not running:
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
			else:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if !is_locked:
		move_and_slide()

