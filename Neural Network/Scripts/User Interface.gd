extends Control

var Available = [true, true]
var File
var Directory

func _ready():
	Directory = DirAccess.make_dir_absolute("C://Users/" + OS.get_environment("USERNAME") + "/AppData/Roaming/Trader Neural Network/")
	if not FileAccess.file_exists("C://Users/" + OS.get_environment("USERNAME") + "/AppData/Roaming/Trader Neural Network/AllWeights.txt"):
		File = FileAccess.open("C://Users/" + OS.get_environment("USERNAME") + "/AppData/Roaming/Trader Neural Network/AllWeights.txt", FileAccess.WRITE)
		File.store_var(Mule.AllWeights)
		File.close()
	elif Mule.Startup:
		File = FileAccess.open("C://Users/" + OS.get_environment("USERNAME") + "/AppData/Roaming/Trader Neural Network/AllWeights.txt", FileAccess.READ)
		Mule.AllWeights = File.get_var()
		File.close()
	
	_Generate_New_Set()

func _Generate_New_Set():
	Mule.LastProfit = 0.0
	Mule.RemainingTime = randi_range(3, 10)
	Mule.InitialTime = Mule.RemainingTime
	$"Remaining Time".text = str(Mule.RemainingTime) + " Day(s) Left"
	
	$"Selling Offer".text = Mule.AllItems.pick_random() + " "
	$"Buying Offer".text = Mule.AllItems.pick_random() + " "
	$"Selling Offer".text += str(min(randi_range(1, 100), Mule.UserMoney))
	$"Buying Offer".text += str(min(randi_range(1, 100), Mule.UserMoney))
	
	Mule.CurrentSellOffer = $"Selling Offer".text.split(" ")
	Mule.CurrentBuyOffer = $"Buying Offer".text.split(" ")
	
	$"User Buy Offer".editable = true
	$"User Sell Offer".editable = true
	Available = [true, true]

func _Update_Day():
	$"Money".text = "Money: " + str(Mule.Money)
	$"UserMoney".text = "User Money: " + str(Mule.UserMoney)
	
	if Mule.Money <= 0 or Mule.UserMoney <= 0:
		Mule.Money = 100
		Mule.UserMoney = 100
		return
	
	if Available[0] and true:
		if randi_range(51, 100) <= 50:
			$"User Buy Offer".text = str(clamp(int(1 / float($"Selling Offer".text.split(" ")[1]) * 2500), 1, Mule.UserMoney))
		else:
			$"User Buy Offer".text = str(clamp(int($"Selling Offer".text.split(" ")[1]) + randi_range(-25, 0), 1, Mule.UserMoney))
		#$"User Buy Offer".text = str(randi_range(1, 100))
	if Available[1] and true:
		$"User Sell Offer".text = str(clamp(int($"Buying Offer".text.split(" ")[1]) + randi_range(0, 25), 1, Mule.Money))
		#$"User Sell Offer".text = str(randi_range(1, 100))
	
	if int($"User Buy Offer".text) >= int($"Selling Offer".text.split(" ")[1]) and Available[0]:
		$"Final Selling Price".text = $"User Buy Offer".text
		$"User Buy Offer".editable = false
		Available[0] = false
	if int($"User Sell Offer".text) <= int($"Buying Offer".text.split(" ")[1]) and Available[1]:
		$"Final Buying Price".text = $"User Sell Offer".text
		$"User Sell Offer".editable = false
		Available[1] = false
	Mule.RemainingTime -= 1
	$"Remaining Time".text = str(Mule.RemainingTime) + " Day(s) Left"
	if Mule.RemainingTime <= 0 or Available == [false, false]:
		_Calculate_Profit()
		get_tree().change_scene_to_file("res://Scenes/Weight Calculator.tscn")
	else:
		_Recalculate_Prices()

func _Calculate_Profit():
	if Available[0]:
		_Deduct_Untraded()
	if Available[1]:
		_Deduct_Untraded()
	
	if $"Final Selling Price".text != "":
		Mule.LastProfit += int($"Final Selling Price".text)
		Mule.Money += int($"Final Selling Price".text)
		Mule.UserMoney -= int($"Final Selling Price".text)
	
	if $"Final Buying Price".text != "":
		Mule.LastProfit -= int($"Final Buying Price".text)
		Mule.Money -= int($"Final Buying Price".text)
		Mule.UserMoney += int($"Final Buying Price".text)
	
	$"Final Buying Price".text = ""
	$"Final Selling Price".text = ""
	$"User Sell Offer".text = ""
	$"User Buy Offer".text = ""
	
	Mule.MoneyStates.append(Mule.Money)
	
	if Mule.MoneyStates.size() == 100:
		var Average = 0
		var Count = 0.0
		for Money in Mule.MoneyStates:
			Average += Money
			Count += 1.0
		Mule.MoneyStates = []
		print("\n")
		print(["Average Money", Average / Count])
		print("\n")

func _Deduct_Untraded():
	var Cursor = 0
	for Weight in Mule.AllWeights:
		Cursor = 0
		for Value in Mule.AllWeights[Weight]:
			Mule.AllWeights[Weight][Cursor] += randf_range(-0.0001, -0.00001)
			Cursor += 1

func _Recalculate_Prices():
	var CurrentSellPrice = int($"Selling Offer".text.split(" ")[1])
	var CurrentUserBuyPrice = int($"User Buy Offer".text)
	var CurrentBuyPrice = int($"Buying Offer".text.split(" ")[1])
	var CurrentUserSellPrice = int($"User Sell Offer".text)
	if CurrentUserBuyPrice <= CurrentSellPrice / 10.0:
		CurrentUserBuyPrice = roundf(CurrentSellPrice + randi_range(-10, 10) + 0.5)
	
	var PriceModifier = roundf(abs(Mule.TotalWeight) * 25 * (randf_range(0, abs(Mule.TotalWeight)) + max(CurrentUserBuyPrice / 100.0, 5)))
	if Mule.TotalWeight < 0:
		CurrentSellPrice -= PriceModifier
		CurrentBuyPrice += PriceModifier
		print(["Lesser Zero Calculation", -PriceModifier])
	elif Mule.TotalWeight > 0:
		CurrentSellPrice += PriceModifier
		CurrentBuyPrice -= PriceModifier
		print(["Greater Zero Calculation", PriceModifier])
	else:
		PriceModifier = int(min((CurrentSellPrice - CurrentUserBuyPrice) / 100.0, 5.0)) * 10
		CurrentSellPrice += int(min((CurrentSellPrice - CurrentUserBuyPrice) / 100.0, 5.0)) * 10
		CurrentBuyPrice -= int(min((CurrentSellPrice - CurrentUserBuyPrice) / 100.0, 5.0)) * 10
		print(["Zero Calculation", int(min((CurrentSellPrice - CurrentUserBuyPrice) / 100.0, 5.0)) * 10])
	CurrentSellPrice = clamp(CurrentSellPrice, 1, Mule.UserMoney)
	CurrentBuyPrice = clamp(CurrentBuyPrice, 1, Mule.Money)
	
	print(["CurrentSellPrice", CurrentSellPrice])
	print(["CurrentUserBuyPrice", CurrentUserBuyPrice])
	print(["CurrentBuyPrice", CurrentBuyPrice])
	print(["CurrentUserSellPrice", CurrentUserSellPrice])
	print(["Total Weight", Mule.TotalWeight, "Sell Price", CurrentSellPrice, "Buy Price", CurrentBuyPrice])
	print(["Money", Mule.Money, "User Money", Mule.UserMoney])
	
	$"Selling Offer".text = $"Selling Offer".text.replace($"Selling Offer".text.split(" ")[1], "")
	$"Selling Offer".text += str(int(CurrentSellPrice))
	$"Buying Offer".text = $"Buying Offer".text.replace($"Buying Offer".text.split(" ")[1], "")
	$"Buying Offer".text += str(int(CurrentBuyPrice))

func _on_progress_day_pressed():
	_Update_Day()
