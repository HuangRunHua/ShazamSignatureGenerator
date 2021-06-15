//
//  ContentView.swift
//  ShazamSignatureGenerator
//
//  Created by Runhua Huang on 2021/6/15.
//

import SwiftUI
import ShazamKit
import AVFoundation

struct ContentView: View {
    // Used to get audio from the microphone.
    private lazy var audioEngine = AVAudioEngine()

    // Used to generate an audio signature from the audio input.
    @available(iOS 15.0, *)
    private lazy var generator = SHSignatureGenerator()
    
    let geneSigAction = SignatureGene()
    
    
    var body: some View {
        VStack(spacing: 32) {
            Button(action: geneSigAction.getAllSignatures) {
                Text("Shazam").padding()
            }
            .frame(width: 200, height: 60)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(30)
        }.padding([.trailing, .leading], 40)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
