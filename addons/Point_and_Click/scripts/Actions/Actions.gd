# Each action will have:
#  - a "function" called when executing
#  - a "text" which can be shown in screen
#  - a "type" which should be either "IMMEDIATE", "INTERACTIVE", "TO_COMBINE",
#	 or COMBINED
#    - IMMEDIATE actions shuold be executed immediatly by the player
#      - say <something> -> player.say(something)
#      - walk_to <object> -> player.walk_to(object)
#    - INTERACTIVE actions should be delegated
#      - examine <object> -> object.examine(player)
#      - open <object> -> object.open(player)
#    - TO_COMBINE actions need two objects to be COMBINED
#      - use_item <this> -> use_item <this> <on that> -> that.use_item(this)
#  - a "object" if the action is "combined", this is the object to combine"
#  - a "nexus" for the text in "combined" actions (i.e. use <this> "with" <that>)

# INTERACTIVE Actions
var examine = Action.new("examine", "Examine", Action.INTERACTIVE)
var go_to = Action.new("go_to", "Go to", Action.INTERACTIVE)
var open = Action.new("open", "Open", Action.INTERACTIVE)
var read = Action.new("read", "Read", Action.INTERACTIVE)
var search = Action.new("search", "Search", Action.INTERACTIVE)
var take = Action.new("take", "Take", Action.INTERACTIVE)
var talk_to = Action.new("talk_to", "Talk to", Action.INTERACTIVE)
var use = Action.new("use", "Use", Action.INTERACTIVE)

# IMMEDIATE Actions
var say = Action.new("say", "", Action.IMMEDIATE)
var walk_to = Action.new("walk_to", " ", Action.INTERACTIVE)

# TO_COMBINE Actions
var use_item = Action.new("use_item", "Use", Action.TO_COMBINE, 'with')

# The empty action
var none = Action.new("", "", Action.IMMEDIATE)
