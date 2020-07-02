class_name Action

const IMMEDIATE = 'immediate'
const INTERACTIVE = 'interactive'
const TO_COMBINE = 'to_combine'
const COMBINED = 'combined'

var function
var text
var orig_text
var type
var orig_type
var object
var nexus = ""


func _init(_func: String, _text:String, _type: String,
		   _nexus: String = ""):
	function = _func
	text = _text
	orig_text = _text
	orig_type = _type
	type = _type
	nexus = _nexus

func combine(obj):
	object = obj
	text = orig_text + " " + obj.oname + " " + nexus
	type = COMBINED

func uncombine():
	object = null
	text = orig_text
	type = orig_type
