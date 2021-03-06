
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
import ulti/[clientnet, board, events, zbag]

// sdk
import structs/[ArrayList, HashMap]
import os/Time

ClientUI: class {

    game: ClientGame
    scene: Scene

    // ui
    frame: Frame
    right, main: Panel
    serverLabel, money, playerName: Label
    playerAvatar: Icon
    streetName, streetPrice, streetGroup, streetOwner: Label

    uiLoader: UILoader

    hose := Firehose new()

    init: func (=game, =scene) {
        frame = Frame new(scene)
        load()
    }

    load: func {
        uiLoader = UILoader new(UIFactory new())
        uiLoader load(frame, "assets/ui/main.yml")
        serverLabel = frame find("server", Label)
        money = frame find("money", Label)
        playerName = frame find("playerName", Label)
        playerAvatar = frame find("playerAvatar", Icon)
        
        main = frame find("main", Panel)
        
        right = frame find("right", Panel)
        uiLoader load(right, "assets/ui/street.yml")

        streetName = frame find("name", Label)
        streetPrice = frame find("price", Label)
        streetGroup = frame find("group", Label)
        streetOwner = frame find("owner", Label)

        frame onAction("join", |a|
            askCode(|code|
                hose publish(ZBag make("join", code))
            )
        )

        frame onAction("create", |a|
            hose publish(ZBag make("create"))
        )
    }

    update: func {
        frame update()

        match (game state) {
            case ClientState WAITING =>
                serverLabel setValue(game net hostname)
                money setValue("")
            case ClientState IN_GAME =>
                serverLabel setValue("")
                money setValue(" | $%.0f" format(game player balance))
        }
    }

    // business

    askNick: func (f: Func (String)) {
        dialog := InputDialog new(frame, "Enter nickname", |s| f(s))
        frame push(dialog)
    }

    askCode: func (f: Func (String)) {
        dialog := InputDialog new(frame, "Enter game code", |s| f(s))
        frame push(dialog)
    }

    showLobby: func {
        uiLoader load(main, "assets/ui/lobby.yml")
    }

    onConnected: func (name: String) {
        main clear()
        uiLoader load(main, "assets/ui/lobby2.yml")
        
        main find("gameName", Label) setValue(name)
    }

    setTileInfo: func (tile: Tile) {
        match (tile) {
            case street: Street =>
                streetName setValue("Street")
                streetPrice setValue("Price: $%.0f" format(street price))
                streetGroup setValue("Group: %s" format(street group name))
                if (street owner) {
                    streetOwner setValue("Owned by: %s" format(street owner name))
                } else {
                    streetOwner setValue("FOR SALE!")
                }
            case =>
                streetName setValue(tile toString() capitalize())
                streetPrice setValue(" ")
                streetGroup setValue(" ")
                streetOwner setValue(" ")
        }
    }

}

