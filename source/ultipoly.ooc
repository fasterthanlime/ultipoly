
// third-party
use deadlogger
import deadlogger/[Log, Logger, Handler, Formatter]

use zombieconfig
import zombieconfig

use dye
import dye/[core, input, sprite, primitives, loop]

use gnaar
import gnaar/[ui, dialogs]

// sdk
import structs/[ArrayList]

// ours
use ultipoly-server
import ulti/[base, board]

main: func (args: ArrayList<String>) {
    Game new()
}

Game: class extends Base {

    dye: DyeContext
    input: Input
    loop: FixedLoop

    scene: Scene
    frame: Frame

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
        input = dye input
        scene = dye getScene()
        frame = Frame new(scene)

        loop = FixedLoop new(dye, 30)

        dialog := InputDialog new(frame, "Game name", |message|
            logger info("Got message: %s", message)
        )
        frame push(dialog)

        loop run(||
            frame update()
            update()
        )
    }

    update: func {
        input onKeyPress(KeyCode ESC, |kp|
            quit()
        )

        input onExit(|| quit())
    }

    quit: func {
        dye quit()
        exit(0)
    }

}
