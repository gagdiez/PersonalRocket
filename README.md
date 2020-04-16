# Personal Godot

A port of the game [personal voxel](https://lunafromthemoon.itch.io/personal-rocket-demo) to the [Godot Engine](https://godotengine.org/). I will most probably not port the whole main, but just enough so I can learn how to properly use GODOT.

The main idea of creating this repo is so that the comunity can use it as an example on their own projects. Godot's documentation is currently not the best, and I was able to learn mostly thanks to other projects. So, as a way to say thanks, I am making my project public. I will try to write the code as clear as possible, while keeping good coding practices.

Currently, I have implemented:

## A basic point and click system.
You can point something, and see its name under the mouse, and click on it to perform an action. There are currently 4 actions: Look, Walk to, Take, and Read. Though only 2 of them actually do something so far. You can change from one action to the other using the mouse wheel.

## A 3D Navigation Mesh (Navmesh).
When "walking to" something, a path will be created using the Navigation system of Godot. Which I was able to understand mostly thanks to [this example](https://github.com/godotengine/godot-demo-projects/tree/master/3d/navmesh)

## A Baked Light Map
To try to keep things performant. I learned how to do this thanks to the [following video](https://www.youtube.com/watch?v=R0y9Li0qBbI)

## Keyboard input handling
I also wanted to learn how to control the main character with the mouse, so besides the point and click, I will surelly add some keyboard input handling. Currently you can control the character with the keyboard arrows.
