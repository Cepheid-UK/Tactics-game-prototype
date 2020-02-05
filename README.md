# Tactics-game-prototype

This is a prototype for a turn-based tactics game using similar movement and combat system to the Advance Wars series.

The movement uses BFS to determine movable area, and A* to locate an acceptable path.

There is a state machine that handles the logic flow between selecting units, giving commands and resolving combat.
