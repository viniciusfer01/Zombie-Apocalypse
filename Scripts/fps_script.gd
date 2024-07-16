extends CharacterBody3D

@onready var client = get_node ( "/root/WebSocketClient" )

var message_block = {}

var SPEED
const JUMP_VELOCITY = 5.0
const gravity = 20

var mouse_sensitivity = 0.1

@onready var head = $Head
@onready var animation_player = $Head/Camera3D/AnimationPlayer

func _ready ():
	Input.set_mouse_mode ( Input.MOUSE_MODE_CAPTURED )
	#get_window ().set_mode ( 3 ) #Full screen

func _input ( event ):
	if event is InputEventMouseMotion:
		rotate_y ( deg_to_rad ( -event.relative.x * mouse_sensitivity ) )
		head.rotate_x ( deg_to_rad ( -event.relative.y * mouse_sensitivity ) )
		head.rotation.x = clamp ( head.rotation.x, deg_to_rad ( -90 ), deg_to_rad ( 90 ) )

func _physics_process ( delta ):
	if Input.is_action_pressed ( "ui_cancel" ):
		#get_window ().set_mode ( 2 ) #Maximized
		Input.set_mouse_mode ( Input.MOUSE_MODE_VISIBLE )
		'''get_node ( "/root/Main/LobbyScene" ).show ()
		get_parent ().queue_free ()'''

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump. Space Bar
	if Input.is_action_just_pressed ( "jump" ) and is_on_floor ():
		velocity.y = JUMP_VELOCITY

		#Send message to server when jumping
		message_block = {
			"type": "position_update",
			"match_id": get_parent ().match_id,
			"transform": var_to_str ( transform )
		}
		client.send ( JSON.stringify ( message_block ) )

	SPEED = 4.0
	#Walk button. Shift
	if Input.is_action_pressed ( "walk" ) :
		SPEED = 1.0

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

	#When moving, send position update and bobs the camera
	if direction != Vector3 ():
		animation_player.play ( "Head Bob" )

		#Send message to server when moving
		message_block = {
			"type": "position_update",
			"match_id": get_parent ().match_id,
			"transform": var_to_str ( transform )
		}
		client.send ( JSON.stringify ( message_block ) )
