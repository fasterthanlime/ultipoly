
// third-party
use deadlogger
import deadlogger/[Log, Logger, Handler, Formatter]

use zombieconfig
import zombieconfig

use dye
import dye/[core, input, sprite, primitives, loop]

use gnaar
import gnaar/[ui, ui-loader, dialogs]

// sdk
import structs/[ArrayList]
import os/Time

// ours
use ultipoly-server
import ulti/[base, board]

import poly/[pboard]

main: func (args: ArrayList<String>) {
    Client new()
}

Client: class extends Base {

    dye: DyeContext
    input: Input
    loop: FixedLoop

    scene: Scene
    frame: Frame

    player: Player
    board: Board
    pboard: PBoard

    // temp code
    steps := 0

    init: func {
        super()
        logger info("Starting up ultipoly...")

        configPath := "config/ultipoly.config"
        config := ZombieConfig new(configPath, |base|
            base("width", "1024")
            base("height", "768")
            base("server", "ultipoly.amos.me")
        )

        width  := config["width"]  toInt()
        height := config["height"] toInt()
        title := "Ultipoly"

        dye = DyeContext new(width, height, title, false)
        dye setClearColor(Color new(50, 50, 50))
        input = dye input
        scene = dye getScene()
        frame = Frame new(scene)

        setupEvents()

        loop = FixedLoop new(dye, 30)

        /*
        dialog := InputDialog new(frame, "Nickname", |message|
            logger info("Got message: %s", message)
        )
        frame push(dialog)
        */

        player = Player new("me")

        uiLoader := UILoader new(UIFactory new())
        uiLoader load(frame, "assets/ui/main.yml")
        time := frame find("time", Label)
        money := frame find("money", Label)
        
        right := frame find("right", Panel)
        uiLoader load(right, "assets/ui/street.yml")

        board = Board new()
        pboard = PBoard new(board)
        scene add(pboard)

        unit := board createUnit(player)
        pboard addUnit(unit)

        loop run(||
            time setValue("%d seconds" format(this steps))
            money setValue("$%.0f" format(player balance))

            frame update()
            update()
        )
    }

    advance: func {
        steps += 1
        for (unit in player units) {
            unit step(1000)
        }
    }

    update: func {
        pboard update()
    }

    setupEvents: func {
        input onKeyPress(KeyCode ESC, |kp|
            quit()
        )

        input onKeyPress(KeyCode SPACE, |kp|
            advance()
        )

        input onExit(|| quit())
    }

    quit: func {
        dye quit()
        exit(0)
    }

}
