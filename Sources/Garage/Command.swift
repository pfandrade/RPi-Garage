//
//  File.swift
//  
//
//  Created by Paulo F. Andrade on 01/09/2019.
//

import Foundation
import Utility
import Basic

protocol Command: class {
    var command: String { get }
    var overview: String { get }
    func register(with parser: ArgumentParser)
    func run(with arguments: ArgumentParser.Result) throws
}

enum CommandErrors: Error {
    case unknownCommand
    case incompleteCommand
}


struct CommandRegistry {
    private let parser: ArgumentParser
    private var commands: [Command] = []
    init(usage: String, overview: String) {
        parser = ArgumentParser(usage: usage, overview: overview)
    }
    mutating func register(command: Command) {
        commands.append(command)
    }
    func run() {
        do {
            commands.forEach { (command) in
                command.register(with: parser)
            }
            let parsedArguments = try parse()
            return try process(arguments: parsedArguments)
        }
        catch let error as ArgumentParserError {
            print(error.description)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func parse() throws -> ArgumentParser.Result {
        let arguments = Array(CommandLine.arguments.dropFirst())
        return try parser.parse(arguments)
    }
    private func process(arguments: ArgumentParser.Result) throws {
        guard let subparser = arguments.subparser(parser),
            let command = commands.first(where: { $0.command == subparser }) else {
                parser.printUsage(on: stdoutStream)
            return
        }
        try command.run(with: arguments)
    }
}
