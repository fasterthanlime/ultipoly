
// third-party
use dye
import dye/[core, primitives, sprite, text, math]

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

    tileLayer, unitLayer: GlGroup

    ptiles := ArrayList<PTile> new()
    punits := ArrayList<PUnit> new()

    init: func (=board) {
        //add(GlText new(FONT_PATH, "%d tiles missing here." format(board tiles size)))
        tileLayer = GlGroup new()
        add(tileLayer)

        unitLayer = GlGroup new()
        add(unitLayer)

        i := 0
        for (tile in board tiles) {
            addTile(tile, i)
            i += 1
        }
    }

    getTilePos: func (tileIndex: Int) -> Vec2 {
        vec2(100 + tileIndex * 120, 200)
    }

    addTile: func (tile: Tile, tileIndex: Int) {
        ptile := PTile new(tile)
        ptile pos set!(getTilePos(tileIndex))
        ptiles add(ptile)
        tileLayer add(ptile)
    }

    addUnit: func (unit: Unit) {
        punit := PUnit new(this, unit)
        punits add(punit)
        unitLayer add(punit)
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

PUnit: class extends GlGroup {

    unit: Unit
    pboard: PBoard

    offset := static vec2(60, 60)

    init: func (=pboard, =unit) {
        sprite := GlSprite new("assets/png/astronaut.png")
        factor := 0.2
        sprite scale set!(factor, factor)

        add(sprite)
        pos set!(pboard getTilePos(unit tileIndex) add(offset))
    }

}

