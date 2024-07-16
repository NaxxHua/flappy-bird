extends CharacterBody2D

const JUMP_VELOCITY = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead = false

signal passed_pipe

func _ready():
	$AnimatedSprite2D.play("default")
	$CollisionArea.body_entered.connect(_on_area_2d_body_entered)

func _physics_process(delta):
	if is_dead:
		return

	# 添加重力
	if not is_on_floor():
		velocity.y += gravity * delta

	# 处理跳跃
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY

	# 移动角色
	move_and_slide()

	# 检测与地面的碰撞
	if is_on_floor():
		_on_Player_hit()

func _on_area_2d_body_entered(body):
	if body.name.begins_with("Pipe"):
		if position.x > body.position.x and not body.has_passed:
			body.has_passed = true
			emit_signal("passed_pipe")
		else:
			_on_Player_hit()

func _on_Player_hit():
	# 游戏重置逻辑
	print("Player hit!")
	is_dead = true
	get_tree().reload_current_scene()
