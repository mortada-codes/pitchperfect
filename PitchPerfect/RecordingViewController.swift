//
//  ViewController.swift
//  PitchPerfect
//
//  Created by mahmoud mortada on 5/21/18.
//  Copyright © 2018 mahmoud mortada. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController,AVAudioRecorderDelegate {

    
    var audioRecorder : AVAudioRecorder!
    var  audioFileName: URL?
    @IBOutlet weak var recordButton : UIButton!
    @IBOutlet weak var stopButton : UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupRecording()
        stopButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
      private func setupRecording(){
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        
         audioFileName = documentDirectory.appendingPathComponent("recordeVoice.m4a")
        let settings = [AVFormatIDKey:Int(kAudioFormatAppleLossless),
                        AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue,
                        AVEncoderBitRateKey:320000,
                        AVNumberOfChannelsKey:2,
                        AVSampleRateKey:44100.0] as [String : Any]
        
        audioRecorder = try? AVAudioRecorder(url: audioFileName!, settings: settings)
        guard audioRecorder != nil else{
            print("Audio Recorder didn't initialized")
            return
        }
        audioRecorder?.delegate = self
        audioRecorder?.prepareToRecord()
        
    }

    @IBAction func recording(_ sender: Any) {
        audioRecorder.record()
        stopButton.isEnabled = true
    }
    
    
    @IBAction func stopRecording(_ sender: Any){
        audioRecorder.stop()
      
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       audioRecorder.stop()
        print("preparing view controller and passing audioFileUrl")
        let soundsViewController = segue.destination as! SoundViewController
        soundsViewController.audioFileName = self.audioFileName
    }
    

    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.performSegue(withIdentifier: "showSounds",sender:self)
    }
    
    
   
    
}

