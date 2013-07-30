
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
import structs/[ArrayList, HashMap]
import os/Time

// ours
use ultipoly-server
import ulti/[base, board, clientnet, zbag]

import poly/[pboard, ui]

ClientGame: class {

    dye: DyeContext
    input: Input
    loop: FixedLoop

    scene: Scene

    board: Board
    pboard: PBoard

    logger := static Log getLogger(This name)

    // net
    net: ClientNet

    // ui
    ui: ClientUI

    // state
    state := ClientState WAITING
    nick: String

    player: Player
    players := HashMap<String, Player> new()

    init: func {
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

        setupEvents()

        ui = ClientUI new(this, scene)
        ui askNick(|message|
            nick = message
            logger info("Joining with nick '%s'", nick)
            net join(nick)
        )

        net = ClientNetImpl new(this)
        net connect(config["server"], config["port"] toInt())

        loop = FixedLoop new(dye, 60)
    }

    run: func {
        loop run(||
            ui update()
            update()
        )
    }

    onBoard: func (=board) {
        pboard = PBoard new(ui, board)
        scene add(pboard)
    }

    start: func {
        state = ClientState IN_GAME
        ui playerName setValue(player name)
        ui playerAvatar src = "assets/png/player-%s.png" format(player avatar)
        logger info("Game started!")
    }

    update: func {
        delta := 1000.0 / 60.0
        net update()

        match state {
            case ClientState IN_GAME =>
                for (unit in player units) {
                    unit fakeStep(delta)
                }

                pboard update()
        }
    }

    setupEvents: func {
        input onKeyPress(KeyCode B, |kp|
            tryBuy()
        )

        input onKeyPress(KeyCode ESC, |kp|
            quit()
        )

        input onExit(|| quit())
    }

    tryBuy: func {
        if (state != ClientState IN_GAME) return

        if (pboard unitSelected) {
            net tryBuy(pboard unitSelected unit tileIndex)
        }
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

    client: ClientGame

    init: func (=client) {
        super()
    }

    onBoard: func (board: Board) {
        logger warn("Received board! here it is:")
        board print()
        client onBoard(board)
    }

    onNewPlayer: func (name, avatar: String) {
        newPlayer := Player new(name, avatar)
        client players put(newPlayer name, newPlayer)
        logger info("Joined the party: %s", newPlayer name)

        if (name == client nick) {
            logger info("Found ourselves!")
            client player = newPlayer
        }
    }

    onNewUnit: func (playerName, hash: String) {
        player := client players get(playerName)
        unit  := client board addUnit(player, hash)
        punit := client pboard addUnit(unit)
        player units add(unit)
        if (playerName == client nick) {
            client pboard selectUnit(punit)
        } else {
            logger info("new unit isn't ours, ignoring... (%s vs %s)", playerName, client nick)
        }
    }

    start: func {
        client start()
    }

    unitEvent: func (bag: ZBag) {
        hash := bag pull()
        unit := client board units get(hash)
        unit applyEvent(bag)
    }

    playerEvent: func (bag: ZBag) {
        name := bag pull()
        player := client players get(name)
        player applyEvent(bag)
    }

    tileBought: func (name: String, tileIndex: Int) {
        tile := client board getTile(tileIndex)
        player := client players get(name)
        tile owner = player
    }

    keepalive: func {
        send(ZBag make("keepalive", client player name))
    }

}

