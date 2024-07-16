extends StaticBody2D

const SPEED = 200.0
@export var has_passed: bool = false  # 添加 has_passed 属性

signal player_passed  # 定义玩家通过信号

func _ready():
	$Area2D.body_entered.connect(_on_area_2d_body_entered)

func _physics_process(delta):
	position.x -= SPEED * delta
	print("Pipe Position: ", position, "Name: ", name)  # 调试输出
	if position.x < -100:
		queue_free()

func _on_area_2d_body_entered(body):
	if body.name == "Player" and not has_passed:
		has_passed = true
		emit_signal("player_passed")
