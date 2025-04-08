extends Control

func _ready():
	_Adjust_Weights()
	_Read_Weights()

func _input(_Event):
	get_tree().change_scene_to_file("res://Scenes/User Interface.tscn")

func _Adjust_Weights():
	var Cursor = 0
	for Child in get_children():
		Child.text = str(Mule.AllWeights["MoneyWeights"][Cursor])
		Cursor += 1

func _Read_Weights():
	var CurrentWeight
	for Child in get_children():
		CurrentWeight = (float(Child.text) + (1 / float(Mule.Money)) / 100) * Mule.AllMultipliers["Money"]
		Mule.TotalWeight += CurrentWeight / 100
