=begin


Robots are deployed in a field of abandoned electronics, their purpose is to refurbish patches of this field into functional tech.

The robots are also capable of self-disassembly and self-replication, but they need raw materials from structures called Recyclers which the robots can build.

The structures will recycle everything around them into raw matter, essentially removing the patches of electronics and revealing the Grass below.

Players control a team of these robots in the midst of a playful competition to see which team can control the most patches of a given scrap field. They do so by marking patches with their team's color, all with the following constraints:
If robots of both teams end up on the same patch, they must disassemble themselves one for one. The robots are therefore removed from the game, only leaving at most one team on that patch.
The robots may not cross the grass, robots that are still on a patch when it is completely recycled must therefore disassemble themselves too.

The game is played on a grid of variable size. Each tile of the grid represents a patch of scrap electronics. The aim of the game is to control more tiles than your opponent, by having robots mark them.

Each tile has the following properties:
scrapAmount: this patch's amount of usable scrap. It is equal to the amount of turns it will take to be completely recycled. If zero, this patch is Grass.
owner: which player's team controls this patch. Will equal -1 if the patch is neutral or Grass.
Robots
Any number of robots can occupy a tile, but if units of opposing teams end the turn on the same tile, they are removed 1 for 1. Afterwards, if the tile still has robots, they will mark that tile.
``
After moving all robots to the middle tile, only one blue robot remains and the tile is marked.
Robots may not occupy a Grass tile or share a tile with a Recycler.
Recyclers
Recyclers are structures that take up a tile. Each turn, the tile below and all adjacent tiles are used for recycling, reducing their scrapAmount and providing 1 unit of matter to the recycler's owner.

If the tile under a recycler runs out of scrap, the recycler is dismantled.

Any tile within reach of your recyclers will grant 1 matter per turn and their scrapAmount will decrease.
A given tile can only be subject to recycling once per turn. Meaning its scrapAmount will go down by 1 even if a player has multiple adjacent Recyclers, providing that player with only 1 unit of matter. If a tile has adjacent Recyclers from both players, the same is true but both players will receive 1 unit of matter.


10 units of matter can be spent to create a new robot, or to build another Recycler.

At the end of each turn, both players receive an extra 10 matter.


On each turn players can do any amount of valid actions, which include:

 move a number of units from a tile to an adjacent tile. You may specify a non adjacent tile to move to, in which case the units will automatically select the best MOVE to approach the target.

A MOVE to (3,0) will result in this robot stepping into (1,2).
BUILD: erect a Recycler on the given empty tile the player controls.

construct a number of robots on the given tile the player controls.

Action order for one turn
BUILD actions are computed.
MOVE and SPAWN actions are computed simultaneously. A robot cannot do both on the same turn.
Units of opposing teams on the same tile are removed one for one.
Remaining robots will mark the tiles they are on, changing their owner.
Recyclers affect the tiles they are on and the 4 adjacent tiles that are not Grass.
Tiles with size 0 are now Grass. Recyclers and robots on that tile are removed.
The players receive 10 base matter as well as the matter from recycling.

Victory Conditions
The winner is the player who controls the most tiles after either:

A player no longer controls a single tile.
20 turns have passed without any tile changing scrapAmount or owner.
200 turns have been played.
Defeat Conditions
Your program does not provide a command in the allotted time or it provides an unrecognized command.


=end

