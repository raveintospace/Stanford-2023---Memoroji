//
//  ScoreForm.swift
//  Memorize
//
//  Created by Uri on 7/4/24.
//

import SwiftUI

struct ScoreForm: View {
    
    @ObservedObject var viewModel: MemorojiViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var playerName: String = ""
    @FocusState private var playerNameFocused: Bool
    
    @State private var showDismissAlert: Bool = false
    
    private let textFieldMaxLength: Int = 8
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section(header: Text("Player name")) {
                        TextField("Player name", text: $playerName)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .focused($playerNameFocused)
                            .submitLabel(.done)
                            .keyboardType(.alphabet)
                            .onChange(of: playerName) { _, newValue in
                                playerName = newValue.filter { $0.isLetter || $0.isNumber }
                                
                                if playerName.count > textFieldMaxLength { playerName = String(playerName.prefix(textFieldMaxLength))
                                }
                            }
                    }
                    Section(header: Text("Deck played")) {
                        Text("\(viewModel.memorizeDecks[viewModel.deckIndex].name)")
                    }
                    Section(header: Text("Total matches")) {
                        Text("\(viewModel.matches)")
                    }
                    Section(header:
                                Text("Final score")
                        .bold()
                        .font(.title)
                    ) {
                        Text("\(viewModel.score)")
                            .bold()
                            .font(.largeTitle)
                    }
                    Section {
                        Button("Save score") {
                            saveScore()
                            dismiss()
                        }
                        .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .onAppear {
                    playerNameFocused = true
                }
                .alert(isPresented: $showDismissAlert) {
                    Alert(
                        title: Text("Exit screen"),
                        message: Text("You will lose your score if you press Exit"),
                        primaryButton: .destructive(Text("Exit")) { dismiss() },
                        secondaryButton: .default(Text("Keep editing"))
                    )
                }
            }
            .navigationTitle("Save your score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DismissXButton {
                        showDismissAlert = true
                    }
                }
            }
        }
    }
}

#Preview {
    ScoreForm(viewModel: MemorojiViewModel())
}

extension ScoreForm {
    
    private func saveScore() {
        viewModel.saveScore(player: playerName, deck: viewModel.memorizeDecks[viewModel.deckIndex].name, matches: viewModel.matches, score: viewModel.score)
    }
}
