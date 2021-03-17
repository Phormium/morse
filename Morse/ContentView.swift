//
//  ContentView.swift
//  Morse
//
//  Created by Леонид Сафронов on 20.06.2020.
//  Copyright © 2020 Леонид Сафронов. All rights reserved.
//

import SwiftUI

class StateController: ObservableObject {
    @Published var abcText              = ""
    @Published var morseText            = ""
    @Published var selection            = 0
    @Published var sModel:SavedModel    = SavedModel(appDelegate: UIApplication.shared.delegate as! AppDelegate)
}

struct ContentView: View {
    @ObservedObject private var state = StateController()
    
    var body: some View {
        TabView(selection: $state.selection){
            TranslationView(state: state)
                .tabItem {
                    VStack {
                        Image("abc")
                        Text("Translation")
                    }
                }
                .tag(0)
            AlphabetView(state: state)
                .tabItem {
                    VStack {
                        Image("alf")
                        Text("Alphabet")
                    }
                }
                .tag(1)
            SavedView(state: state)
                .tabItem {
                    VStack {
                        Image("star")
                        Text("Saved")
                    }
                }
                .tag(2)
        }
    }
}

struct TranslationView: View {
    @ObservedObject private var state:StateController
    @State private var story:[SavedTranslation]     = []
    @State private var hModel:HistoryModel          = HistoryModel(appDelegate: UIApplication.shared.delegate as! AppDelegate)
    @State private var plaingLight                  = false
    @State private var stopLight                    = false
    @State private var plaingSound                  = false
    @State private var stopSound                    = false

    init(state:StateController) {
        self.state = state
        
    }
    
    private func abcToMorse(changed: Bool) {
        state.morseText = ""
        let tmpText = state.abcText.lowercased()
        for l in tmpText {
            var changed = false
            for (i, lt) in Morse.letters.enumerated() {
                if l == lt {
                    state.morseText += Morse.morseLetters[i] + " "
                    changed = true
                    break
                }
            }
            if !changed {
                state.morseText = ""
                return
            }
        }
        
        if state.abcText == "" {
            return
        }

        for s in story {
            if s.absText.lowercased() == state.abcText.lowercased() {
                return
            }
        }

        hModel.addItem(abc: state.abcText, morse: state.morseText)
        story = hModel.getData()
    }
    
    private func morseToAbc(changed: Bool) {
        state.abcText = ""
        let tmpText = state.morseText
        
        if state.abcText.last != " " && state.abcText.count != 0 {
            state.abcText += " "
        }
        
        var char = ""
        for (j,l) in tmpText.enumerated() {
            if (l != " ") && (j != tmpText.count-1) {
                char += String(l)
            } else {
                var changed = false
                for (i,lt) in Morse.morseLetters.enumerated() {
                    if lt == char {
                        state.abcText += String(Morse.letters[i])
                        changed = true
                        char = ""
                        break
                    }
                }
                if !changed {
                    state.abcText = ""
                    return
                }
            }
        }
        
        if state.morseText == "" {
            return
        }

        for s in story {
            if s.absText.lowercased() == state.abcText.lowercased() {
                return
            }
        }

        hModel.addItem(abc: state.abcText, morse: state.morseText)
        story = hModel.getData()
    }
    
    private func playSound() {
        if stopSound {
            return
        }
        if !stopSound && plaingSound{
            stopSound = true
            return
        }
        let queue = DispatchQueue.global(qos: .utility)
        let tmpMorse = state.morseText
        queue.async{
            self.plaingSound = true
            for i in tmpMorse {
                if i == " " {
                    usleep(200000)
                    continue
                }
                if i == "/" {
                    usleep(600000)
                    continue
                }
                Morse.toggleSound()
                if i == "." {
                    usleep(100000)
                } else {
                    usleep(300000)
                }
                Morse.toggleSound()
                if self.stopSound {
                    self.stopSound = false
                    break
                }
                usleep(100000)
            }
            self.plaingSound = false
        }
    }
    
    private func playLight() {
        if stopLight {
            return
        }
        if !stopLight && plaingLight{
            stopLight = true
            return
        }
        let queue = DispatchQueue.global(qos: .utility)
        let tmpMorse = state.morseText
        queue.async{
            self.plaingLight = true
            for i in tmpMorse {
                if i == " " {
                    usleep(200000)
                    continue
                }
                if i == "/" {
                    usleep(600000)
                    continue
                }
                Morse.toggleFlash()
                if i == "." {
                    usleep(100000)
                } else {
                    usleep(300000)
                }
                Morse.toggleFlash()
                if self.stopLight {
                    self.stopLight = false
                    break
                }
                usleep(100000)
            }
            self.plaingLight = false
        }
    }
    
    private func save() {
        if state.morseText != "" && state.abcText != "" {
            abcToMorse(changed: true)
            for s in state.sModel.getData() {
                if s.absText.lowercased() == state.abcText.lowercased() {
                    return
                }
            }
            state.sModel.addItem(abc: state.abcText, morse: state.morseText)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(alignment: .leading) {
                    Text("Text:")
                        .multilineTextAlignment(.leading)
                        .frame(height: CGFloat(25))
                    HStack {
                        VStack(alignment: .leading) {
                            TextField("Enter text", text: self.$state.abcText, onEditingChanged: self.abcToMorse)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.init(red: 0.3, green: 0.3, blue: 0.3), lineWidth: 1)
                                )
                                .frame(width: geometry.size.width * 7/8 - 10, height: CGFloat(35))
                            Text("Morse:")
                                .multilineTextAlignment(.leading)
                                .frame(height: CGFloat(25))
                            TextField(". -. - . .-. / - . -..- -", text: self.$state.morseText, onEditingChanged: self.morseToAbc)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.init(red: 0.3, green: 0.3, blue: 0.3), lineWidth: 1)
                                )
                                .frame(width: geometry.size.width * 7/8 - 10, height: CGFloat(35))
                        }
                        VStack {
                            Button(action: {
                                self.save()
                            }) {
                                Image("save")
                                    .renderingMode(.template)
                                    .foregroundColor(.blue)
                                    .frame(width: geometry.size.width * 1/8 - 10)
                                    
                            }
                            Button(action: {
                                self.playLight()
                            }) {
                                ZStack {
                                    Image("light")
                                        .renderingMode(.template)
                                        .foregroundColor(.blue)
                                        .frame(width: geometry.size.width * 1/8 - 10)
                                    if self.plaingLight {
                                        Rectangle()
                                            .frame(width: 20, height: 2)
                                            .rotationEffect(.degrees(45))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            Button(action: {
                                self.playSound()
                            }) {
                                ZStack {
                                    Image("sound")
                                        .renderingMode(.template)
                                        .foregroundColor(.blue)
                                        .frame(width: geometry.size.width * 1/8 - 10)
                                    if self.plaingSound {
                                        Rectangle()
                                            .frame(width: 20, height: 2)
                                            .rotationEffect(.degrees(45))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                            .frame(height: 110)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.init(red: 0.3, green: 0.3, blue: 0.3), lineWidth: 1)
                            )
                    }
                    Text("History:")
                        .multilineTextAlignment(.leading)
                        .frame(height: CGFloat(25))
                }
                
                GeometryReader { geom in
                    List(self.story){ st in
                        Button(action: {
                            self.state.abcText    = st.absText
                            self.state.morseText  = st.morseText
                        }) {
                            VStack(alignment: .leading) {
                                Text(st.absText)
                                Text(st.morseText)
                            }
                                .frame(width: geometry.size.width - 10, alignment: .leading)

                        }
                    
                    }
                        .frame(width: geometry.size.width - 10, height: geom.size.height - 10, alignment: .center)
                }
            }
        }
            .onAppear {
                self.story = self.hModel.getData()
            }
    }
}

struct SavedView: View {
    @ObservedObject private var state:StateController
    
    init(state:StateController) {
        self.state = state
    }
    
    private func deleteItems(at offsets: IndexSet) {
        offsets.forEach { state.sModel.removeItem(at: $0) }
        state.selection = 2
    }
    
    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(self.state.sModel.getData()) { st in
                    Button(action: {
                        self.state.abcText      = st.absText
                        self.state.morseText    = st.morseText
                        self.state.selection    = 0
                    }) {
                        VStack(alignment: .leading) {
                            Text(st.absText)
                            Text(st.morseText)
                        }
                            .padding(.horizontal, 20)
                    }
                }
                    .onDelete(perform: self.deleteItems)
            }
                .padding(.horizontal, -20)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct AlphabetView: View {
    @ObservedObject private var state:StateController
    @State private var abc:[SavedTranslation]   = []
    
    init(state:StateController) {
        self.state = state
    }
    
    var body: some View {
        GeometryReader { geometry in
            List(self.abc){ st in
                HStack {
                    Text(st.absText)
                        .frame(width: geometry.size.width / 2)
                    Text(st.morseText)
                        .frame(width: geometry.size.width / 2)
                }
                    .padding(.horizontal, 10)
                    
            }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .padding(.horizontal, -10)
        }
            .onAppear {
                self.abc = []
                for i in 1..<Morse.letters.count {
                    self.abc.append(SavedTranslation(absText: String(Morse.letters[i]), morseText: Morse.morseLetters[i]))
                }
            }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    }
}
#endif
