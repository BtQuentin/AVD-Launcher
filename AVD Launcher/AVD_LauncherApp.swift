//
//  AVD_LauncherApp.swift
//  AVD Launcher
//
//  Created by BtQuentin on 08/07/2025.
//

import Foundation
import SwiftUI
import SystemConfiguration

@main
struct AVDLauncherApp: App {
    init() {
        guard let emulatorPath = findEmulatorPath() else {
                return
            }
        UserDefaults.standard.register(defaults: [
            "devices": executeProcessAndReturnResult(
                emulatorPath,
                arguments: ["-list-avds"]
            )
        ])
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .overlay(alignment: .topTrailing) {
                    Button(
                        "Exit",
                        systemImage: "xmark.circle.fill"
                    ) {
                        NSApp.terminate(nil)
                    }
                    .labelStyle(.titleAndIcon)
                    .buttonStyle(.plain)
                    .padding(6)
                }
                .frame(width: 300, height: 180)
        } label: {
            Label{
                Text("AVD Launcher")
            } icon: {
                let image: NSImage = {
                    let ratio = $0.size.height / $0.size.width
                    $0.size.height = 18
                    $0.size.width = 18 / ratio
                    return $0
                }(NSImage(named: "MenuBarIcon")!)
                
                Image(nsImage: image)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}

func executeProcessAndReturnResult(_ command: String, arguments: [String]) -> String {
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

func executeDaemonProcess(_ command: String, arguments: [String]) {
    let process = Process()
    process.launchPath = "/bin/zsh"
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = arguments
    process.unbind(.isIndeterminate)

    do {
        if #available(macOS 13.0, *) {
            try process.run()
        } else {
            process.launch()
        }
    } catch {
        print("Error launching process: \(error.localizedDescription)")
    }
}

func processOutput(output: String?, updateLines: @escaping ([String]) -> Void) {
    guard let output = output else {
        updateLines([])
        return
    }

    // Split output
    let lines = output.split(separator: "\n").map { String($0) }

    // Update lines
    updateLines(lines)
}

func findEmulatorPath() -> String? {
    let env = ProcessInfo.processInfo.environment

    // Search for `emulator`
    if let sdkPath = env["HOME"] {
        let emulatorPath = "\(sdkPath)/Library/Android/sdk/emulator/emulator"
        if FileManager.default.fileExists(atPath: emulatorPath) {
            return emulatorPath
        }
    }

    return nil
}
