//
//  DoorCommand.swift
//  Basic
//
//  Created by Paulo F. Andrade on 01/09/2019.
//

import Foundation
import Utility
import SwiftyGPIO

class DoorCommand: Command {
    let command = "door"
    let overview = "Open, close or check the status of the garage door"
    
    private enum Action: String, CaseIterable, ArgumentKind {
        static var completion: ShellCompletion = .unspecified
        init(argument: String) throws {
            guard let _ = Action(rawValue: argument) else {
                throw CommandErrors.unknownCommand
            }
            self.init(rawValue: argument)!
        }
        
        case open = "open"
        case close = "close"
        case status = "status"
    }
    
    private enum ActionResponse: String {
        case open = "OPEN"
        case opening = "OPENING"
        case closed = "CLOSED"
        case closing = "CLOSING"
    }
    
    private var action: PositionalArgument<DoorCommand.Action>?
    
    func register(with parser: ArgumentParser) {
        let subparser = parser.add(subparser: command, overview: overview)
        let actions = Action.allCases.map { $0.rawValue }.joined(separator: "|")
        action = subparser.add(positional: "door action \(actions)", kind: DoorCommand.Action.self)
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        
        guard
            let subcommand = action,
            let action = arguments.get(subcommand) else {
            throw CommandErrors.incompleteCommand
        }
        let response: ActionResponse
        switch action {
        case .open:
            if (!open) {
                pressButton()
                response = .opening
            }
            else {
                response = .open
            }
        case .close:
            if (open) {
                pressButton()
                response = .closing
            } else {
                response = .closed
            }
        case .status:
            response = open ? .open : .closed
        }
        print(response.rawValue)
    }
    
    private let sensorPin: GPIO
    private let buttonPin: GPIO

    init(sensorPin: GPIOName, buttonPin: GPIOName) throws {
        let gpios = SwiftyGPIO.GPIOs(for: .RaspberryPiRev2)
        
        guard
            let sensorGPIO = gpios[sensorPin],
            let buttonGPIO = gpios[buttonPin] else {
            throw Errors.failedGPIOInit
        }
        buttonGPIO.direction = .OUT
        sensorGPIO.direction = .IN
        sensorGPIO.pull = .up
        
        self.sensorPin = sensorGPIO
        self.buttonPin = buttonGPIO
    }
    
    var open: Bool {
        return self.sensorPin.value == 1
    }
    
    private func pressButton() {
        buttonPin.value = 1
        Thread.sleep(forTimeInterval: 0.5)
        buttonPin.value = 0
    }
}
