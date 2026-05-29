# Clue Card Dispenser

The clue-card dispenser is a simple friction-roller mechanism embedded in POIROT's abdomen. It delivers one laminated clue card per manual actuation.

## Bill of Materials

| Component | Specification | Qty |
|---|---:|---:|
| DC gear motor | GA12-N20, 6V, 50 rpm | 1 |
| Friction roller | 3D-printed roller with rubber O-rings | 1 |
| Card housing | PLA 3D-printed stack holder | 1 |
| Switch | SPST mechanical toggle or push switch | 1 |
| Power supply | USB-A 5V adapter or power bank | 1 |
| Wiring | 2-pin cable | 1 |

## Operating Principle

1. Place laminated clue cards in a vertical stack.
2. The roller sits above the top card.
3. Press the switch to power the motor.
4. Rubber O-rings on the roller provide enough friction to advance one card.
5. Release the switch after about 1.2 seconds.

No MCU, encoder, or feedback loop was used in the study version. Timing was manually tuned for a human-paced delivery rhythm.

## Figure

![Mechanical dispenser](../../docs/figures/Mechanical%20Dispenser.png)

## Notes

The local source folder contains the technical report and appendix diagram, but not the final printable CAD for this module. If the final STL/Rhino/STEP files are available, place them in this directory before public release.
