//
//  EmulatorViewModel.swift
//  AVD Launcher
//
//  Created by BtQuentin on 08/07/2025.
//

import Foundation
import Combine

class EmulatorViewModel: ObservableObject {
    @Published var devices: String = ""
    @Published var lines: [String] = []

    // Initialisation pour récupérer la liste des émulateurs
    init() {
        fetchEmulatorList()
    }

    // Fonction pour récupérer la liste des émulateurs
    func fetchEmulatorList() {
        guard let emulatorPath = findEmulatorPath() else {
                self.devices = "Can't find 'emulator' tool."
                self.lines = []
                return
            }
        
        self.devices = executeProcessAndReturnResult(
            emulatorPath,
            arguments: ["-list-avds"]
        )
        processOutput(output: devices)
    }

    // Fonction pour rafraîchir la liste des émulateurs
    func refreshEmulatorList() {
        fetchEmulatorList()
    }

    // Fonction pour traiter la sortie du processus et mettre à jour les lignes
    private func processOutput(output: String?) {
        guard let output = output else {
            self.lines = []
            return
        }

        // Découper la sortie en lignes
        self.lines = output.split(separator: "\n").map { String($0) }
    }

    // Fonction pour exécuter un processus et retourner le résultat
    private func executeProcessAndReturnResult(_ command: String, arguments: [String]) -> String {
        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = pipe
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments

        do {
            if #available(macOS 13.0, *) {
                try process.run()
            } else {
                process.launch()
            }
        } catch {
            return "Error: \(error.localizedDescription)"
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    // Fonction pour démarrer un émulateur spécifique
    func startEmulator(for device: String) {
        guard let emulatorPath = findEmulatorPath() else {
                self.devices = "Can't find 'emulator' tool."
                self.lines = []
                return
            }
        
        executeDaemonProcess(
            emulatorPath,
            arguments: ["@\(device)"]
        )
    }
}
