//
//  MorseCode.swift
//  Morse
//
//  Created by Леонид Сафронов on 22.06.2020.
//  Copyright © 2020 Леонид Сафронов. All rights reserved.
//

import Foundation
import AVFoundation

class Morse {
    static var letters:[Character]  = [ " ", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" ]
    static var morseLetters         = [ "/", "._", "_...", "_._.", "_..", ".", ".._.", "__.", "....", "..", ".___", "_._", "._..",  "__", "_.", "___", ".__.", "__._", "._.", "...", "_", ".._", "..._", ".__", "_.._", "_.__", "__..", ".____", "..___", "...__", "...._", ".....", "_....", "__...", "___..", "____.", "_____"]
    
    private static var sound: AVAudioPlayer?
    private static var soundPlaying = false

    
    static func toggleFlash() {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if (device!.hasTorch) {
            do {
                try device!.lockForConfiguration()
                if (device!.torchMode == AVCaptureDevice.TorchMode.on) {
                    device!.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try device!.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                device!.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    static func toggleSound() {
        if !soundPlaying {
            soundPlaying = true
            let path = Bundle.main.path(forResource: "pop.mp3", ofType:nil)!
            let url = URL(fileURLWithPath: path)

            do {
                sound = try AVAudioPlayer(contentsOf: url)
                sound?.play()
            } catch {
                print("error load sound")
            }
        } else {
            soundPlaying = false
            sound?.stop()
        }
    }
}
