class_name Action

const IMMEDIATE = 'immediate'
const INTERACTIVE = 'interactive'
const TO_COMBINE = 'to_combine'
const COMBINED = 'combined'
const INTERNAL = 'internal'

var function
var text
var orig_text
var type
var orig_type
var combine_object
var nexus = ""

func _init(_func: String, _text:String, _type: String,
		   _nexus: String = ""):
	function = _func
	text = _text
	orig_text = _text
	orig_type = _type
	type = _type
	nexus = _nexus

func combine(_combine_object):
	combine_object = _combine_object
	text = orig_text + " " + combine_object.oname + " " + nexus
	type = COMBINED

func uncombine():
	combine_object = null
	text = orig_text
	type = orig_type

func execute(whom, what):
	
	if not function:
		return
	
	whom.interrupt()
	
	match type:
		IMMEDIATE:
			whom.call(function, what)
		INTERACTIVE:
			what.call(function, whom)
		COMBINED:
			if combine_object != what:
				what.call(function, whom, combine_object)
		INTERNAL:
			if what is Array:
				whom.internal(function, what)
			else:
				printerr("execute was expecting an array")
