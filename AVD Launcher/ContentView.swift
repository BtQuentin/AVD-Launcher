//
//  ContentView.swift
//  AVD Launcher
//
//  Created by BtQuentin on 08/07/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = EmulatorViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.lines.isEmpty {
                if viewModel.devices == "Can't find 'emulator' tool." {
                    Text("Can't find 'emulator' tool.")
                        .padding(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("No device")
                        .padding(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            // Liste des lignes retournées par le processus
            ForEach(viewModel.lines, id: \.self) { line in
                Button(action: {
                    viewModel.startEmulator(for: line)
                }) {
                    Text(line)
                        .padding(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Divider()
            // Ajouter un bouton de rafraîchissement en haut
            Button(action: {
                viewModel.fetchEmulatorList()
            }) {
                Label("Refresh", systemImage: "arrow.clockwise.circle.fill")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }.labelStyle(.titleAndIcon)
        }
        .padding()
        .onAppear {
            // Charger la liste des émulateurs à l'apparition de la vue
            viewModel.fetchEmulatorList()
        }
    }
}
