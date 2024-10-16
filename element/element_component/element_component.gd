@tool
extends Node2D
class_name ElementComponent


enum Direction
{
	UP, RIGHT, DOWN, LEFT
}

# 每个电路允许输入的电力类型
# 如果电路不支持该电力类型，则无法在该电路上输入或输出电力
# 对于一个电路，只有二种情况：允许全部类型（ALL），允许单一类型
# 这个枚举的类型定义位置十分关键，前面的类型顺序必须时刻与 Electricity.Type 保持同步
enum AllowInputType
{
	RED, BLUE, YELLOW, PURPLE, ORANGE, GREEN, WHITE, ALL
}

@export var surface_texture: Texture2D:
	set(new_texture):
		surface_texture = new_texture
		$Control/Surface.texture = new_texture

# 当前元件的四个电路的数据，在元件被顺时针旋转后进行滚动
# 按照下标依次为：上，右，下，左
@export var line_disabled_array: Array[bool] = [false, false, false, false]
@export var line_inputable_array: Array[bool] = [true, true, true, true]
@export var line_outputable_array: Array[bool] = [true, true, true, true]
@export var line_allow_input_type_array: Array[AllowInputType] = [
	AllowInputType.ALL, AllowInputType.ALL,
	AllowInputType.ALL, AllowInputType.ALL
]
@export var line_output_type_array: Array[Electricity.Type] = [
	Electricity.Type.RED, Electricity.Type.RED,
	Electricity.Type.RED, Electricity.Type.RED
]

@onready var electricity_array: Array[Electricity] = [$Electricity1, $Electricity2, $Electricity3, $Electricity4]
var line_active_array: Array[bool] = [false, false, false, false]
	
	
func fill_core(electricity_type: Electricity.Type) -> void:
	$Control/Core.color = Tables.ElectricityColorTable.get(electricity_type)


func clear_core() -> void:
	$Control/Core.color = Tables.ElectricityColorTable.get(Electricity.Type.WHITE)


func output_electricity(dir: Direction) -> void:
	if line_disabled_array[dir] == true:
		return
	if line_outputable_array[dir] == false:
		return
	electricity_array[dir].output(line_output_type_array[dir])
	
	
func output_electricity_with_type(type: Electricity.Type, dir: Direction) -> void:
	if line_disabled_array[dir] == true:
		return
	if line_outputable_array[dir] == false:
		return
	electricity_array[dir].output(type)
	
	
func input_electricity(type: Electricity.Type, dir: Direction) -> void:
	if line_disabled_array[dir] == true:
		return
	if line_inputable_array[dir] == false:
		return
	if check_line_allow_input_type(type, dir) == false:
		return
	electricity_array[dir].input(type)
	await get_tree().create_timer(0.4).timeout
	fill_core(type)
	
	
func check_line_allow_input_type(type: Electricity.Type, dir: Direction) -> bool:
	if line_allow_input_type_array[dir] == AllowInputType.ALL:
		return true
	if line_allow_input_type_array[dir] == type:
		return true
	else:
		return false
		
