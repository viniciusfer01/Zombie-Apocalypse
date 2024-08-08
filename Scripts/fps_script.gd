extends CharacterBody3D

@onready var client = get_node ( "/root/WebSocketClient" )

var message_block = {}

var SPEED
const JUMP_VELOCITY = 5.0
const gravity = 20

var mouse_sensitivity = 0.1

@export_subgroup ( "Weapons" )
@export var weapons: Array [ Weapon ] = [
	preload ( "res://Weapons/blasterP.tres" ),
	preload ( "res://Weapons/blasterE.tres" )
]

var weapon: Weapon
var weapon_index := 0

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var animation_player = $Head/Camera3D/AnimationPlayer
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var hand = $Head/Camera3D/Hand
@onready var blaster_cooldown = $Timer
@onready var crosshair = $Head/Camera3D/TextureRect

func _ready ():
	Input.set_mouse_mode ( Input.MOUSE_MODE_CAPTURED )

	weapon = weapons [ weapon_index ]
	initiate_change_weapon ( weapon_index )


func _input ( event ):
	if event is InputEventMouseMotion:
		rotate_y ( deg_to_rad ( -event.relative.x * mouse_sensitivity ) )
		head.rotate_x ( deg_to_rad ( -event.relative.y * mouse_sensitivity ) )
		head.rotation.x = clamp ( head.rotation.x, deg_to_rad ( -90 ), deg_to_rad ( 90 ) )

func fire ():
	if Input.is_action_pressed ( "fire" ):
		if !blaster_cooldown.is_stopped (): return
		Audio.play ( weapon.sound_shoot )

		blaster_cooldown.start ( weapon.cooldown )

		if raycast.is_colliding ():
			var target = raycast.get_collider ()
			if target.is_in_group ( "Enemy" ):
				target.health -= weapons [ weapon_index ].damage

func _physics_process ( delta ):
	if Input.is_action_pressed ( "ui_cancel" ):
		Input.set_mouse_mode ( Input.MOUSE_MODE_VISIBLE )
		'''get_node ( "/root/Main/LobbyScene" ).show ()
		get_parent ().queue_free ()'''

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump. Space Bar
	if Input.is_action_just_pressed ( "jump" ) and is_on_floor ():
		velocity.y = JUMP_VELOCITY

	SPEED = 4.0
	#Walk button. Shift
	if Input.is_action_pressed ( "walk" ) :
		SPEED = 1.0

	fire ()

	# Get the input direction and handle the movement/deceleration. WASD
	var input_dir = Input.get_vector ( "move_left", "move_right", "move_foward", "move_backward" )
	var direction = ( transform.basis * Vector3 ( input_dir.x, 0, input_dir.y ) ).normalized ()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward ( velocity.x, 0, SPEED )
		velocity.z = move_toward ( velocity.z, 0, SPEED )

	move_and_slide ()

	#When moving, bobs the camera
	if direction != Vector3 ():
		animation_player.play ( "Head Bob" )

	if Input.is_action_just_pressed ( "weapon_toggle" ):
		weapon_index = wrap ( weapon_index + 1, 0, weapons.size () )
		initiate_change_weapon ( weapon_index )

		message_block = {
			"type": "weapon_toggled",
			"match_id": get_parent ().match_id,
			"weapon_index": weapon_index
		}
		client.send ( JSON.stringify ( message_block ) )

	#Send position update to server
	message_block = {
		"type": "position_update",
		"match_id": get_parent ().match_id,
		"transform": var_to_str ( transform ),
		"head_transform": var_to_str ( head.transform )
	}
	client.send ( JSON.stringify ( message_block ) )

func initiate_change_weapon ( index ):
	weapon_index = index
	change_weapon ()

func change_weapon ():
	weapon = weapons [ weapon_index ]

	for child in hand.get_children ():
		hand.remove_child ( child )

	var weapon_model = weapon.model.instantiate ()
	hand.add_child ( weapon_model )

	weapon_model.position = weapon.position
	weapon_model.rotation_degrees = weapon.rotation

	crosshair.texture = weapon.crosshair
	raycast.target_position = Vector3 ( 0, 0, -1 ) * weapon.max_distance

	Audio.play ( "Sounds/weapon_change.ogg" )
