
// third-party
use deadlogger
import deadlogger/[Log, Logger]

use zombieconfig
import zombieconfig

use dye
import dye/[core, input, sprite, primitives, loop]

// sdk
import structs/[ArrayList]

main: func (args: ArrayList<String>) {
    Game new()
}

Game: class {

    dye: DyeContext
    input: Input
    loop: FixedLoop

    init: func {
        logger := Log getLogger("client")
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

        loop = FixedLoop new(dye, 30)

        loop run(||
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
