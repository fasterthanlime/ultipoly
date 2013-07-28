
// third-party
use dye
import dye/[core, primitives, sprite, text]

// ours
use ultipoly-server
import ulti/[board]

// sdk
import structs/[ArrayList]

/**
 * Displays the board
 */
PBoard: class extends GlGroup {

    FONT_PATH := static "assets/ttf/font.ttf"

    board: Board
    ptiles := ArrayList<PTile> new()

    init: func (=board) {
        add(GlText new(FONT_PATH, "%d tiles missing here." format(board tiles size)))

        x := 100
        y := 100

        for (tile in board tiles) {
            ptile := PTile new(tile)
            ptile pos set!(x, y)
            addTile(ptile)
            x += 120
        }
    }

    addTile: func (ptile: PTile) {
        ptiles add(ptile)
        add(ptile)
    }

}

PTile: class extends GlGroup {

    tile: Tile

    sprites: GlGroup
    bg, fg: GlSprite

    init: func (=tile) {
        sprites = GlGroup new()
        factor := 0.4
        sprites scale set!(factor, factor)
        add(sprites)

        bg = GlSprite new("assets/png/tile-color.png")
        bg center = false
        match tile {
            case street: Street =>
                color := street group rgb
                bg color set!(color r, color g, color b)
        }
        sprites add(bg)


        fg = GlSprite new("assets/png/tile.png")
        fg center = false
        sprites add(fg)

        text := match tile {
            case street: Street =>
                // good for you
                "$%.0f" format(street price)
            case =>
                tile toString()
        }
        label := GlText new(PBoard FONT_PATH, text, 18)
        label pos set!(5, 5)
        label color set!(25, 25, 25)
        add(label)
    }

}

