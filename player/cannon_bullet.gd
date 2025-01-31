extends Projectile

func _ready():
	projectile_type = "cannon_bullet"
	set_physics_process(false)
