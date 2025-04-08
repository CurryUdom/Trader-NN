extends Node

var AllWeights = Mule.AllWeights
var CalculatedValue = 0.0
var Multiplier = 1.0
var Maximum = 0.0001
var Minimum = 0.0
var File

func _ready():
	_Calculate_Weights()

func _input(_Event):
	get_tree().change_scene_to_file("res://Scenes/Weight - Time.tscn")

func _Calculate_Weights():
	var WeightMultiplier = 0.00001
	var StoredWeights = []
	Minimum = Mule.LastProfit / 10000000
	Maximum = Mule.LastProfit / 1000000
	
	for Key in AllWeights.keys():
		StoredWeights = []
		for Weight in AllWeights[Key]:
			if Mule.LastProfit == 0:
				StoredWeights.append(randf_range(-0.000005, -0.0000025))
			else:
				StoredWeights.append(Weight + WeightMultiplier * Mule.LastProfit + (abs(Minimum) / Minimum) * randf_range(abs(Minimum), abs(Maximum)))
		Mule.AllWeights[Key] = StoredWeights
	
	File = FileAccess.open("C://Users/" + OS.get_environment("USERNAME") + "/AppData/Roaming/Trader Neural Network/AllWeights.txt", FileAccess.WRITE)
	File.store_var(Mule.AllWeights)
	File.close()
	
	print(Mule.AllWeights)
