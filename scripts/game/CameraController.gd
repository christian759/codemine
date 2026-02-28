extends Camera2D
class_name CameraController

var trauma: float = 0.0
@export var max_x: float = 20.0
@export var max_y: float = 20.0
@export var max_r: float = 5.0
@export var trauma_power: float = 2.0
@export var decay: float = 0.8

var noise = FastNoiseLite.new()
var noise_y = 0

func _ready():
add_to_group("CameraController")
noise.seed = randi()
noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

func add_trauma(amount: float):
trauma = min(trauma + amount, 1.0)

func _process(delta):
if trauma > 0:
= max(trauma - decay * delta, 0.0)
= Vector2.ZERO
_degrees = 0

func _shake():
var amount = pow(trauma, trauma_power)
noise_y += 1
rotation_degrees = max_r * amount * noise.get_noise_2d(noise.seed, noise_y)
offset.x = max_x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
offset.y = max_y * amount * noise.get_noise_2d(noise.seed * 3, noise_y)
