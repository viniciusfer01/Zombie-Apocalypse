extends CharacterBody3D

var health = 100

func _ready ():
	add_to_group("Enemy")

func _process ( delta ):
	if health <= 0:
		queue_free ()
