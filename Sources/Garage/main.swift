import Foundation
import SwiftyGPIO

do {
    var commands = CommandRegistry(usage: "<subcommand> <action>", overview: "Garage Manager")
    commands.register(command: try DoorCommand(sensorPin: .P18, buttonPin: .P17))
    commands.run()
} catch {
    exit(-1)
}

exit(0)
