
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
import ulti/[base, board, clientnet]

import poly/[pboard]

main: func (args: ArrayList<String>) {
    Client new()
}

Client: class extends Base {

    dye: DyeContext
    input: Input
    loop: FixedLoop

    scene: Scene

    player: Player
    board: Board
    pboard: PBoard

    // temp code
    steps := 0

    // ui
    frame: Frame
    time, money: Label

    // net
    net: ClientNet

    // state
    state := ClientState WAITING

    init: func {
        super()
        logger info("Starting up ultipoly...")

        configPath := "config/ultipoly.config"
        config := ZombieConfig new(configPath, |base|
            base("width", "1024")
            base("height", "768")
            base("server", "ultipoly.amos.me")
            base("port", "5555")
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

        dialog := InputDialog new(frame, "Nickname", |message|
            logger info("Joining with nick '%s'", message)
            net join(message)
        )
        frame push(dialog)

        player = Player new("me")

        loadUI()

        net = ClientNetImpl new(this)
        net connect("tcp://%s:%s" format(config["server"], config["port"]))

        loop = FixedLoop new(dye, 60)
        loop run(||
            frame update()
            update()
        )
    }

    joined: func (=board) {
        pboard = PBoard new(board)
        scene add(pboard)

        unit := board createUnit(player)
        pboard addUnit(unit)

        state = ClientState IN_GAME
    }

    loadUI: func {
        uiLoader := UILoader new(UIFactory new())
        uiLoader load(frame, "assets/ui/main.yml")
        time = frame find("time", Label)
        money = frame find("money", Label)
        
        right := frame find("right", Panel)
        uiLoader load(right, "assets/ui/street.yml")

    }

    update: func {
        net update()

        match state {
            case ClientState IN_GAME =>
                pboard update()
                time setValue("%d seconds" format(this steps))
                money setValue("$%.0f" format(player balance))
        }
    }

    setupEvents: func {
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

ClientState: enum {
    WAITING
    IN_GAME
}

ClientNetImpl: class extends ClientNet {

    client: Client

    init: func (=client) {
        super()
    }

    onBoard: func (board: Board) {
        logger warn("Received board! here it is:")
        board print()
        client joined(board)
    }

}

