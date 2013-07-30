
// third-party
use dye
import dye/[core, primitives, sprite, text, math]

use deadlogger
import deadlogger/[Log, Logger]

// ours
use ultipoly-server
import ulti/[board]
import poly/[ui]

// sdk
import structs/[ArrayList, HashMap]

/**
 * Displays the board
 */
PBoard: class extends GlGroup {

    FONT_PATH := static "assets/ttf/font.ttf"

    board: Board

    tileLayer, unitLayer: GlGroup

    ptiles := ArrayList<PTile> new()
    punits := HashMap<String, PUnit> new()

    unitSelected: PUnit

    logger := Log getLogger(This name)

    ui: ClientUI

    init: func (=ui, =board) {
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

    addUnit: func (unit: Unit) -> PUnit {
        punit := PUnit new(this, unit)
        punits put(unit hash, punit)
        unitLayer add(punit)
        punit
    }

    selectUnit: func (target: PUnit) {
        logger info("Selected unit: %s", target unit hash)
        for (punit in punits) {
            punit selected = false
        }
        unitSelected = target
        target selected = true
    }

    update: func {
        for (ptile in ptiles) {
            ptile update()
        }

        for (punit in punits) {
            punit update()
        }

        if (unitSelected) {
            idealCamPos := vec2(240 - unitSelected pos x, unitSelected pos y - 250)
            pos interpolate!(idealCamPos, 0.1)

            tile := board getTile(unitSelected unit tileIndex)
            if (tile) {
                ui setTileInfo(tile)
            }
        }
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

    update: func {
    }

}

PUnit: class extends GlGroup {

    unit: Unit
    pboard: PBoard
    selected := false

    offset := static vec2(60, 60)

    // graphicsy stuff
    sprite: GlSprite
    timeout: GlText

    init: func (=pboard, =unit) {
        sprite = GlSprite new("assets/png/player-%s.png" format(unit player avatar))
        factor := 0.2
        sprite scale set!(factor, factor)

        add(sprite)
        pos set!(pboard getTilePos(unit tileIndex) add(offset))

        timeout = GlText new(PBoard FONT_PATH, "0s", 18)
        timeout color set!(20, 20, 20)
        timeout pos set!(-40, 40)
        add(timeout)
    }

    update: func {
        if (!unit action) return

        match (unit action type) {
            case ActionType MOVE =>
                target := getTarget(unit action number)

                if (target x < pos x) {
                    pos x = 0
                }
                pos interpolate!(target, 0.15)
            case =>
                target := getTarget(unit tileIndex)
                pos set!(target)
        }

        seconds := unit action timeout / 1000.0
        timeout value = "%s | %.1fs" format(unit action type toString(), seconds)
    }

    getTarget: func (tileIndex: Int) -> Vec2 {
        pboard getTilePos(tileIndex) add(offset) 
    }

}

