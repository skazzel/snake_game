extends Node

@export var snakeScene : PackedScene

var scode : int
var gameStarted : bool = false

# grid
var cells : int = 20
var cell_size : int = 50

var oldData : Array
var snakeData : Array
var snake : Array

var foodPos : Vector2
var regenFood : bool = true

var startPos = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var moveDirection : Vector2
var canMove : bool 
var score = 0

func _ready():
	new_game()
	
func new_game():
	get_tree().call_group("segments", "queue_free")
	get_tree().paused = false
	%Timer.start()
	%gameOver.hide()
	%score.get_node("scoreLabel").text = "Score: " + str(score)
	moveDirection = up
	canMove = true
	generate_snake()
	move_food()
	
func generate_snake():
	oldData.clear()
	snakeData.clear()
	snake.clear()
	
	for i in range(3):
		add_segment(startPos + Vector2(0, i))
		
func add_segment(pos):
	snakeData.append(pos)
	var snakeSegment = snakeScene.instantiate()
	snakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(snakeSegment)
	snake.append(snakeSegment)
	
func _process(delta):
	move_snake()
	
func move_snake():
	if canMove:
		if Input.is_action_just_pressed("down") and moveDirection != up:
			moveDirection = down
			canMove = false
			if not game_started:
				game_started()
		if Input.is_action_just_pressed("up") and moveDirection != down:
			moveDirection = up
			canMove = false
			if not game_started:
				game_started()
		if Input.is_action_just_pressed("left") and moveDirection != right:
			moveDirection = left
			canMove = false
			if not game_started:
				game_started()
		if Input.is_action_just_pressed("right") and moveDirection != left:
			moveDirection = right
			canMove = false
			if not game_started:
				game_started()
		
func game_started():
	gameStarted = true
	%Timer.start()
		
func _on_timer_timeout():
	canMove = true
	oldData = [] + snakeData
	snakeData[0] += moveDirection
	for i in range(len(snakeData)):
		if i > 0:
			snakeData[i] = oldData[i - 1]
		snake[i].position = (snakeData[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()
	
func check_out_of_bounds():
	if snakeData[0].x < 0 or snakeData[0].x > cells - 1 or snakeData[0].y < 0 or snakeData[0].y > cells - 1:
		end_game()

func check_self_eaten():
	for i in range(1, len(snakeData)):
		if snakeData[0] == snakeData[i]:
			end_game()
		
func move_food():
	regenFood = true
	while regenFood:
		regenFood = false
		foodPos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		for i in snakeData:
			if foodPos == i:
				regenFood = true
	$food.position = (foodPos * cell_size) + Vector2(0, cell_size)
	regenFood = true

func check_food_eaten():
	if snakeData[0] == foodPos:
		score += 1
		%score.get_node("scoreLabel").text = "Score: " + str(score)
		add_segment(oldData[-1])
		move_food()

func end_game():
	%gameOver.show()
	%Timer.stop()
	gameStarted = false
	get_tree().paused = true


func _on_game_over_restart():
	new_game()
