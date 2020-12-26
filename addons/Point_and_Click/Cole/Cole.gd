extends Player

# Do not worry about this class - The example player should be enough
# for making most of the things a classic Point and Click adventure needs

func _ready():
	._ready()
	
	# For a player, we need to indicate its "Animation Player"
	animation_player = $Animations

	# Its talk bubble
	talk_bubble = $"Talk Bubble"
	talk_bubble.visible = false

	talk_bubble_timer = $"Talk Bubble/Timer"

	# And where to place it
	talk_bubble_offset = Vector3(-.6, 9.5, 0)

# A little function to test that our cutscene system is working
func test_function(p1, p2, p3):
	print("Cole is printing: ", p1, " ", p2, " ", p3)
