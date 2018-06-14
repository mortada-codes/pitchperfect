//
//  SoundViewController.swift
//  PitchPerfect
//
//  Created by mahmoud mortada on 5/25/18.
//  Copyright © 2018 mahmoud mortada. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class SoundViewController:UIViewController, AVAudioPlayerDelegate{

    var audioSession : AVAudioSession!
    
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioFile: AVAudioFile!
    var timer : Timer!
    var audioFileName : URL?
    @IBOutlet weak var btnPause: UIButton!
    
    @IBOutlet weak var btnslow: UIButton!
    
    @IBOutlet weak var btnFast: UIButton!
    
    @IBOutlet weak var btnReverb: UIButton!
    @IBOutlet weak var btnChipmunks: UIButton!
    @IBOutlet weak var btnEcho: UIButton!
    @IBOutlet weak var btnVader: UIButton!
    override func viewDidLoad() {
        print("init soundsViewController\(String(describing: self.audioFileName))")
        prepareAudioPlayer(url: self.audioFileName!)
        
    }
    
  
    @IBAction func playAsReverb(_ sender: Any) {
        
         self.enablsControls(enable: false)
        playSound(reverb:true)
       
    }
    @IBAction func playAsEcho(_ sender: Any) {
        
         self.enablsControls(enable: false)
        playSound(echo: true)
        
    }
    
    @IBAction func playAsChipmunk(_ sender: Any) {
      
         self.enablsControls(enable: false)
        playSound(pitch: 1000)
      
    }
    @IBAction func playAsSlow(_ sender: Any) {
       
         self.enablsControls(enable: false)
        playSound(rate: 0.5)
        
    }
    @IBAction func playAsFast(_ sender: Any) {
        
        self.enablsControls(enable: false)
        playSound(rate:1.5)
        
        
    }
    @IBAction func playAsDarthvader(_ sender: UIButton) {
        
        self.enablsControls(enable: false)
        playSound(pitch: -1000)
        
    }
    @IBAction func pausePlayer(_ sender: Any) {
     
        if (audioPlayerNode?.isPlaying == true){
            self.stopAudio()
        configUI( isPlay: false)
        }else{
            self.playSound()
            enablsControls(enable: false)
        configUI( isPlay: true)
        }
       
    }
    
    private func configUI( isPlay: Bool){
        if isPlay == true {
             let image  = UIImage(named: "play_active")
           
            btnPause.setImage(image, for: .normal)
            
        }else {
            let image  = UIImage(named: "pause-active")
            btnPause.setImage(image, for: .normal)
            
        }
       
    }
    
    private func prepareAudioPlayer( url:URL){
        do{
            audioFile = try AVAudioFile(forReading : url)
        } catch {
            print(error)
           
          //  showAlert()
        }
        
    }
    
    
    private func enablsControls(enable:Bool  = true ){
        btnEcho.isEnabled  = enable
        btnFast.isEnabled  = enable
        btnslow.isEnabled = enable
        btnVader.isEnabled = enable
        btnReverb.isEnabled = enable
        btnChipmunks.isEnabled = enable
    }
    private func showAlert(title:String?, message:String?) {
        let alert = UIAlertController( title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: title, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func playSound(rate: Float? = nil,pitch:Float? = nil,echo:Bool = false,reverb:Bool = false ){
        
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        let changeRateNode = AVAudioUnitTimePitch()
        if let rate  = rate{
            changeRateNode.rate = rate
        }
        
        if let pitch = pitch {
            changeRateNode.pitch = pitch
        }
        audioEngine.attach(changeRateNode)
        
       let echoUnitNode = AVAudioUnitDistortion()
        echoUnitNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoUnitNode)
    
        let reverbNode = AVAudioUnitReverb()
            reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        if  echo == true && reverb == true {
            connectAudioNodes(nodes: audioPlayerNode,changeRateNode,reverbNode,echoUnitNode,audioEngine.outputNode)
        }else if echo == true{
              connectAudioNodes(nodes: audioPlayerNode,changeRateNode,echoUnitNode,audioEngine.outputNode)
        }else if reverb == true{
              connectAudioNodes(nodes: audioPlayerNode,changeRateNode,reverbNode,audioEngine.outputNode)
        }else{
              connectAudioNodes(nodes: audioPlayerNode,changeRateNode,audioEngine.outputNode)
        }
        
        
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil){
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime){
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                }else {
                       delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            self.timer = Timer(timeInterval: delayInSeconds ,target: self, selector: #selector(SoundViewController.stopAudio),userInfo:nil,repeats: false)
            RunLoop.main.add(self.timer, forMode: RunLoopMode.defaultRunLoopMode)
            
        }
        
        do{
            try audioEngine.start()
        }catch{
            print(error)
        }
            audioPlayerNode.play()
        configUI(isPlay: true)
    }
    
    
    private func connectAudioNodes(nodes:AVAudioNode...){
        for x in 0..<nodes.count-1{
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
   
    
  
    
    @objc func stopAudio(){
        enablsControls()
        if let audioPlayerNode = self.audioPlayerNode {
            audioPlayerNode.stop()
        }
        if let audioEngine = self.audioEngine{
            audioEngine.stop()
            audioEngine.reset()
        }
        if let timer = self.timer{
            timer.invalidate()
        }
        configUI(isPlay: false)
    }
    

    @IBAction func newRecording(_ sender: Any) {
      self.navigationController?.popViewController(animated: true)
    }
}
