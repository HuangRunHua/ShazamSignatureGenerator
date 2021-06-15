//
//  GenerateSignature.swift
//  ShazamSignatureGenerator
//
//  Created by Runhua Huang on 2021/6/15.
//
//  ~/Library/Developer/CoreSimulator/Devices/
//
//  本程序严格按照 “#WWDC21” 的标准，并不生成.shazamcatalog文件
//  .shazamcatalog文件在可在实际使用.shazamsignature文件的程序内生成
//  “#WWDC21”中Apple官方示例代码并未生成.shazamcatalog文件
//  示例代码在实际工程文件中通过使用addReferenceSignature()方法将多个.shazamsignature文件和各自的representing item组合起来，并返回customCatalog
//
//  本程序针对一个音频文件生成对应的.shazamsignature文件
//  由于songAndItems内部有6个词键，因此最终生成6个.shazamsignature文件
//

import Foundation
import ShazamKit
import AVFoundation

class SignatureGene {

    // 所有的音频文件名与匹配的Item
    let songsAndItems = [
        "起风了": SHMediaItem(properties: [.title: "起风了", .subtitle: "眨眼的瞬间，回忆吹了进来", .song: 1, .singer: "动漫唯美风"]),
        "若能绽放光芒": SHMediaItem(properties: [.title: "若能绽放光芒", .subtitle: "你驻足于春色中，于那独一无二的春色之中", .song: 2, .singer: "石川绫子"]),
        "学校不允许乱壁咚^.^": SHMediaItem(properties: [.title: "学校不允许乱壁咚^.^", .subtitle: "单身狗保护协会", .song: 3, .singer: "橘卫门"]),
        "Flower Dance": SHMediaItem(properties: [.title: "Flower Dance", .subtitle: "玫瑰到了花期", .song: 4, .singer: "up初相识"]),
        "Windy Hill": SHMediaItem(properties: [.title: "Windy Hill", .subtitle: "愿你我，终有一天，在风丘下相遇", .song: 5, .singer: "羽肿"]),
        "风居住的街道": SHMediaItem(properties: [.title: "风居住的街道", .subtitle: "那一夜我睡在自己的青春里", .song: 6, .singer: "Yukiko"])
    ]
    
    // 生成单个音频的签名
    func geneSignature(string: String, item: SHMediaItem)->SHSignatureGenerator {
        let signatureGenerator = SHSignatureGenerator()
        generateASignatureAndCatalogFromAudioFile(string: string, item: item, signatureGenerator: signatureGenerator)
        return signatureGenerator
    }
    

    
    func generateASignatureAndCatalogFromAudioFile(string: String, item: SHMediaItem, signatureGenerator: SHSignatureGenerator) {
        guard let audioURL = Bundle.main.url(forResource: string, withExtension: "m4a") else {
            return
        }

        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else {
            return
        }
        do {
            let audioFile = try AVAudioFile(forReading: audioURL)
            let pcmBlock: ((AVAudioPCMBuffer) -> Void) = { buffer in
                do {
                    try signatureGenerator.append(buffer, at: nil)
                } catch {
                    // Handle signature generator error
                    print("9")
                }
            }
            convert(audioFile: audioFile, outputFormat: audioFormat, pcmBlock: pcmBlock)

        } catch {
            // Handle audio file error
            print("8")
        }

        let signature = signatureGenerator.signature()
        // see if we got a signature and if it has a duration
        print(string)
        print("signature: \(String(describing: signature))")
        print("signature duration: \(signature.duration)")
    }
    

    
    func writeSignatureToFile(signatureGenerator: SHSignatureGenerator, fileName: String) {
        // write out the catalog to a file
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(fileName)
            .appendingPathExtension("shazamsignature")

        do {
            try signatureGenerator.signature().dataRepresentation.write(to: tempURL, options: .atomic)
            print("\(tempURL)")
        } catch {
            print("11")
        }
    }

    func getCustomSignature(string: String, item: SHMediaItem) {
        writeSignatureToFile(signatureGenerator: geneSignature(string: string, item: item), fileName: string)
    }
    
    // 最终调用的函数
    func getAllSignatures() {
        songsAndItems.forEach{ song, item in
            getCustomSignature(string: song, item: item)
        }
    }


    func convert(audioFile: AVAudioFile, outputFormat: AVAudioFormat, pcmBlock: (AVAudioPCMBuffer) -> Void) {

        let frameCount = AVAudioFrameCount(
            (1024 * 64) / (audioFile.processingFormat.streamDescription.pointee.mBytesPerFrame)
        )
        let outputFrameCapacity = AVAudioFrameCount(
             round(Double(frameCount) * (outputFormat.sampleRate / audioFile.processingFormat.sampleRate))
        )

        guard let inputBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCount),
              let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: outputFrameCapacity) else {
                  print("6")
            return
        }

        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            do {
                try audioFile.read(into: inputBuffer)
                outStatus.pointee = .haveData
                return inputBuffer
            } catch {
                if audioFile.framePosition >= audioFile.length {
                    outStatus.pointee = .endOfStream
                    print("1")
                    return nil
                } else {
                    outStatus.pointee = .noDataNow
                    print("2")
                    return nil
                }
            }
        }

        guard let converter = AVAudioConverter(from: audioFile.processingFormat, to: outputFormat) else {
            print("3")
            return
        }

        while true {

            let status = converter.convert(to: outputBuffer, error: nil, withInputFrom: inputBlock)
            if status == .error || status == .endOfStream {
                print("5")
                return
            }
            pcmBlock(outputBuffer)
            if status == .inputRanDry {
                print("4")
                return
            }
            inputBuffer.frameLength = 0
            outputBuffer.frameLength = 0
        }
    }
    
    
    
    
}
