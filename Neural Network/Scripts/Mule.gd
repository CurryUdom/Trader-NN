extends Node

var TotalWeight = 0.0
var LastProfit = 0.0
var RemainingTime = 0
var InitialTime = 0

var AllMultipliers = {
	"Time": 3.0,
	"Money": 4.0,
}

var AllWeights = {
	"TimeWeights" = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
	"MoneyWeights" = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
}

var AllItems = ["Food", "Clothes", "Rent"]

var CurrentBuyOffer = ["", 0.0]
var CurrentSellOffer = ["", 0.0]

var Money = 100
var UserMoney = 100

var MoneyStates = []

var Startup = true
