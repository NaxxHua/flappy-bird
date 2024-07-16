extends Node2D

@export var PipeScene : PackedScene
@export var ScoreLabel : Label  # 得分显示
var screen_width : int = 800  # 默认屏幕宽度
var screen_height : int = 600  # 默认屏幕高度
var pipe_counter : int = 0  # 管子计数器
var pipe_gap : int = 250  # 管子间隙
var pipe_height : int = 400  # 管子固定高度
var score : int = 0  # 得分

func _ready():
	screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	screen_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	print("Screen Width: ", screen_width, " Screen Height: ", screen_height)  # 调试输出

	if PipeScene == null:
		print("Error: PipeScene is not loaded correctly")
		return
	else:
		print("PipeScene is loaded correctly")

	$PipeTimer.timeout.connect(_on_PipeTimer_timeout)
	$PipeTimer.start(2.0)  # 延迟2秒后启动定时器

	var player = get_node("Player")
	player.passed_pipe.connect(_on_Player_passed_pipe)

	# 初始化得分
	score = 0
	update_score()

func _on_PipeTimer_timeout():
	# 生成上下成对的管子
	var pipe_instance_top = PipeScene.instantiate() as StaticBody2D
	var pipe_instance_bottom = PipeScene.instantiate() as StaticBody2D

	# 检查实例化是否成功
	if pipe_instance_top == null or pipe_instance_bottom == null:
		print("Error: Pipe instance is null")
		return

	# 随机生成间隙位置
	var gap_y_position = randf_range(pipe_height + pipe_gap / 2, screen_height - pipe_height - pipe_gap / 2)

	# 设置管子的位置
	pipe_instance_top.position = Vector2(screen_width + 50, gap_y_position - pipe_gap / 2 - pipe_instance_top.get_node("Sprite2D").texture.get_height() / 2)
	pipe_instance_bottom.position = Vector2(screen_width + 50, gap_y_position + pipe_gap / 2 + pipe_instance_bottom.get_node("Sprite2D").texture.get_height() / 2)
	
	# 缩放管子高度
	pipe_instance_top.scale.y = (gap_y_position - pipe_gap / 2) / float(pipe_instance_top.get_node("Sprite2D").texture.get_height())
	pipe_instance_bottom.scale.y = (screen_height - gap_y_position - pipe_gap / 2) / float(pipe_instance_bottom.get_node("Sprite2D").texture.get_height())

	pipe_counter += 1
	pipe_instance_top.name = "PipeTop" + str(pipe_counter)  # 设置唯一标识符
	pipe_instance_bottom.name = "PipeBottom" + str(pipe_counter)  # 设置唯一标识符

	# 添加标记，表示管子是否已通过
	pipe_instance_top.set("has_passed", false)
	pipe_instance_bottom.set("has_passed", false)

	# 将管子添加到场景中
	add_child(pipe_instance_top)
	add_child(pipe_instance_bottom)

	# 连接管子的信号
	pipe_instance_top.player_passed.connect(self._on_Player_passed_pipe)
	pipe_instance_bottom.player_passed.connect(self._on_Player_passed_pipe)

func _on_Player_passed_pipe():
	score += 1
	update_score()

func update_score():
	if ScoreLabel != null:
		ScoreLabel.text = str(score)
