
// third-party
use deadlogger
import deadlogger/[Log, Logger, Handler, Formatter]

use gnaar
import gnaar/[ui, ui-loader, dialogs]

use dye
import dye/[core, input, sprite, primitives, loop]


// ours
import poly/[game]

use ultipoly-server
import ulti/[clientnet, board]

// sdk
import structs/[ArrayList, HashMap]
import os/Time

ClientUI: class {

    game: ClientGame
    scene: Scene

    // ui
    frame: Frame
    right: Panel
    time, money, playerName: Label

    init: func (=game, =scene) {
        frame = Frame new(scene)
        load()
    }

    load: func {
        uiLoader := UILoader new(UIFactory new())
        uiLoader load(frame, "assets/ui/main.yml")
        time = frame find("time", Label)
        money = frame find("money", Label)
        playerName = frame find("playerName", Label)
        
        right = frame find("right", Panel)
        uiLoader load(right, "assets/ui/street.yml")
    }

    update: func {
        frame update()

        match (game state) {
            case ClientState WAITING =>
                time setValue("Joining...")
                money setValue(game net hostname)
            case ClientState IN_GAME =>
                time setValue("In game")
                money setValue("$%.0f" format(game player balance))
        }
    }

    // business

    askNick: func (f: Func (String)) {
        dialog := InputDialog new(frame, "Enter nickname", |s| f(s))
        frame push(dialog)
    }

}

