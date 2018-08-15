tool
extends Node2D

# JSON Format
# type - type of dialog
# id - identification for dialog
# actor - who is speaking/type of node
# title -
# name - the actually dialog
# next - id of the next dialog
# choices -
# branches -
# variable -
# value - 

#Constants
#Dict Keys
const typeKey = "type"
const idKey = "id"
const actorKey = "actor"
const titleKey = "title"
const nameKey = "name"
const nextKey = "next"
const choiceKey = "choices"
const branchKey = "branches"
const variableKey = "variable"
const valueKey = "value"
const defaultKey = "_default"
#Dialog Types
const textType = "Text"
const choiceType = "Choice"
const setType = "Set"
const branchType = "Branch"
const nodeType = "Node"

#Nodes
export(NodePath) var dialogPanel # Panel where dialog is
export(NodePath) var dialogText # Dialog text being displayed
export(NodePath) var actorPanel #Panel that displays actor 
export(NodePath) var actorText # Actor text being displayed

var optionsButtonArray = []
export(NodePath) var optionsButton1
export(NodePath) var optionsButton2
 
#Dialog Variables
var dialogShowing = false #Determines whether the dialog panel should be hidden or not

#Dialog Database
export(String, FILE, "*.json") var scriptFile = ""
export(String) var playerActor = "Player"
var dialogArray #Root JSON of the database. Contains all dialog objects
var currentDialog #The current dialog object (usually the one being displayed)
var nextID #Dialog ID of the next dialog object to be seen
var choiceIDs #An array of ids for the choices
var valueDict = {}

func _ready():
	#Load Talkit dialog JSON
	var file = File.new()
	file.open(scriptFile, File.READ)
	var parse = JSON.parse(file.get_as_text())
	file.close()
	dialogArray = parse.result
	
	#Setting relevant variables
	dialogPanel = get_node(dialogPanel)
	dialogText = get_node(dialogText)
	actorPanel = get_node(actorPanel)
	actorText = get_node(actorText)
	optionsButton1 = get_node(optionsButton1)
	optionsButton2 = get_node(optionsButton2)
	optionsButtonArray.append(optionsButton1)
	optionsButtonArray.append(optionsButton2)


func _process(delta):
	if dialogPanel != null:
		dialogPanel.visible = dialogShowing

func _input(event):
	if event.is_action_pressed("ui_accept") and dialogShowing:
		advanceDialog()

func startDialog(id):
	if !dialogShowing:
		dialogShowing = true
		currentDialog = getDialogDict(id)
		if currentDialog != null:
			getNextID()
			resolveDialog()
		else:
			#Print to console that the id is invalid
			endDialog()
		

func advanceDialog():
	if nextID != null:
		currentDialog = getDialogDict(nextID)
		getNextID()
		resolveDialog()
	elif choiceIDs != null:
		setDialogChoices()
	else:
		endDialog()

func endDialog():
	dialogShowing = false
	dialogText.clear()

func resolveDialog():
	var type = currentDialog[typeKey]
	if type == textType:
		setDialogText()
	elif type == choiceType:
		setDialogText()
	elif type == setType:
		setValue()
	elif type == branchType:
		resolveBranch()
	elif type == nodeType:
		endDialog()
	else:
		endDialog()

func setDialogText():
	var textStr = currentDialog[nameKey]
	var actorStr = currentDialog[actorKey]
	setActorText(actorStr)
	dialogText.clear()
	dialogText.add_text(textStr) 

func setDialogChoices():
	for i in range(choiceIDs.size()):
		var choiceDialog = getDialogDict(choiceIDs[i])
		optionsButtonArray[i].setOptionDict(choiceDialog)

func clearDialogChoices():
	choiceIDs = null
	for i in range(optionsButtonArray.size()):
		optionsButtonArray[i].clearChoice()

func setValue():
	var variable = currentDialog[variableKey]
	var value = currentDialog[valueKey]
	valueDict[variable] = value
	advanceDialog()

func resolveBranch():
	var branchDict = currentDialog[branchKey]
	var variable = currentDialog[variableKey]
	if valueDict.has(variable):
		var value = valueDict[variable]
		if branchDict.has(value):
			nextID = branchDict[value]
		else:
			nextID = branchDict[defaultKey]
	else:
		nextID = branchDict[defaultKey]
	advanceDialog()

func setActorText(actor):
	if actor != "":
		actorPanel.visible = true
		actorText.clear()
		actorText.add_text(actor)
	else:
		actorPanel.visible = false

func getDialogDict(id):
	var dialogDict
	for i in dialogArray:
		if i[idKey] == id:
			dialogDict = i
			break
	if dialogDict != null and !dialogDict.has(actorKey):
		dialogDict[actorKey] = playerActor
	return dialogDict

func getNextID():
	if currentDialog.has(nextKey):
		nextID = currentDialog[nextKey]
	elif currentDialog.has(choiceKey):
		choiceIDs = currentDialog[choiceKey]
		nextID = null
	else:
		nextID = null