extends Resource
class_name Weapon

@export_subgroup ( "Model" )
@export var model: PackedScene  # Model of the weapon
@export var position: Vector3  # On-screen position
@export var rotation: Vector3  # On-screen rotation

@export_subgroup ( "Properties" )
@export_range ( 0.1, 1.5 ) var cooldown: float = 0.1  # Firerate
@export_range ( 1, 100 ) var max_distance: int = 100  # Fire distance
@export_range ( 0, 100 ) var damage: float = 100  # Damage per hit

@export_subgroup ( "Sounds" )
@export var sound_shoot: String  # Sound path

@export_subgroup ( "Crosshair" )
@export var crosshair: Texture2D  # Image of crosshair on-screen
