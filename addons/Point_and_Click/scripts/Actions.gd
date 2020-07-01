# Each action will have:
#  - a "function" called when executing
#  - a "text" which can be shown in screen
#  - a "type" which should be either "immediate" or "combined"
#    - immediate actions shuold be executed immediatly (i.e. examine <object>)
#    - combined actions need two objects to be done (i.e. use <this> <on that>)
#  - a "object" if the action is "combined", this is the object to combine"
#  - a "nexus" for the text in "combined" actions (i.e. use <this> "with" <that>)


var walk_to = Action.new("walk_to", " ", Action.IMMEDIATE)
var take = Action.new("take", "Take", Action.IMMEDIATE)
var go_to = Action.new("go_to", "Go to", Action.IMMEDIATE)
var read = Action.new("read", "Read", Action.IMMEDIATE)
var examine = Action.new("examine", "Examine", Action.IMMEDIATE)
var search = Action.new("search", "Search", Action.IMMEDIATE)
var use = Action.new("use", "Use", Action.IMMEDIATE)
var open = Action.new("open", "Open", Action.IMMEDIATE)
var talk_to = Action.new("talk_to", "Talk to", Action.IMMEDIATE)
var use_item = Action.new("use_item", "Use", Action.TO_COMBINE, 'with')
var say = Action.new("say", "", Action.IMMEDIATE)


# The empty action
var none = Action.new("", "", Action.IMMEDIATE)
