
// third-party
use dye
import dye/[core, primitives, sprite, text]

// ours
use ultipoly-server
import ulti/[board]

// sdk

/**
 * Displays the board
 */
PBoard: class extends GlGroup {

    board: Board

    init: func (=board) {
        add(GlText new("assets/ttf/font.ttf", "%d tiles missing here." format(board tiles size)))
    }

}
