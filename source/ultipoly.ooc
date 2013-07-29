
// ours
use ultipoly-server
import ulti/[base]

import poly/[game, pboard]

// sdk
import structs/[ArrayList]

main: func (args: ArrayList<String>) {
    Client new()
}

Client: class extends Base {

    init: func {
        super()
        logger info("Starting up ultipoly...")

        game := ClientGame new()
        game run()
    }

}

