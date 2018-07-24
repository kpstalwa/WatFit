//
//  MotionViewController.swift
//  WatFitProt
//
//  Created by Karam Puneet Talwandi on 2018-06-12.
//  Copyright © 2018 GTN. All rights reserved.
//

import UIKit
import SystemConfiguration
import AVFoundation
class MotionViewController: UIViewController {
    var syncGroup = DispatchGroup()
    var timeTillStart = 3
    var timer = Timer()
    var currentExc : Exercise?
    let m = gfunction()
    
    //audio player variables
    var delayAudioPlayer = AVAudioPlayer() //for 3 second delay
    
   
    @IBOutlet weak var startTicker: UILabel!
    @IBOutlet weak var progressImg: UIImageView!
    
    @IBOutlet weak var setLimit: UILabel!
    @IBOutlet weak var repLimit: UILabel!
    @IBOutlet weak var currentReps: UILabel!
    //incase finish button is called

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RestPage" {
            let timerVC = segue.destination as! TimerViewController
            timerVC.currentExc = currentExc
        }
        else if segue.identifier == "finishExercise" {
            let scoreVC = segue.destination as! ScoreViewController
            scoreVC.currentExc = currentExc
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func finishExercise(_ sender: Any) {
        m.motion.stopDeviceMotionUpdates()
        if(setLimit.text == "1"){
        performSegue(withIdentifier: "finishExercise", sender: currentExc)
    }
        else {
            performSegue(withIdentifier: "RestPage", sender: currentExc)
        }
    }
    
    
    @objc func updateTimer() {
        if(timeTillStart > 0){
        timeTillStart = timeTillStart-1
        startTicker.text = "\(timeTillStart)"
        }
        else{
            startTicker.text = "Go!"
            if(delayAudioPlayer.isPlaying){
                delayAudioPlayer.currentTime = 0
                delayAudioPlayer.play()
            }
            else{
                delayAudioPlayer.play() //start playing the sound
            }
            m.startRecord()
            timer.invalidate()
            syncGroup.notify(queue: .main){
                print("set finished, back in motion view")
                self.m.motion.stopDeviceMotionUpdates()
                if(self.setLimit.text == "1"){
                    self.performSegue(withIdentifier: "finishExercise", sender: self.currentExc)
                }
                else{
                    self.performSegue(withIdentifier: "RestPage", sender: self.currentExc)
            }
        }
    }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //motion setting
        m.staticUpper = (currentExc?.staticUpper)!
        m.StaticLower = (currentExc?.staticLower)!
        m.goodResetLower = (currentExc?.goodResetLower)!
        m.goodActionUpper = (currentExc?.goodActionUpper)!
        m.formConstrainPitch = (currentExc?.formConstrainPitch)!
        m.exercise = currentExc!
        m.quantity = (currentExc?.reps)!
        m.setUpdateInterval(time: 0.02)
        m.currentReps = currentReps
        m.syncGroup = syncGroup
        m.progressImg = progressImg
        
        //initialize AudioPlayer
        
        do{
            delayAudioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "resume", ofType: "mp3")!))
        }
        catch{
            print(error)
        }
        
        delayAudioPlayer.prepareToPlay()
        
        
        startTicker.text = "\(timeTillStart)"
        //3 second wait until recording
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Perform Exercise"
        setLimit!.text! = String(describing: currentExc!.sets!)
        repLimit!.text! = String(describing: currentExc!.reps!)
        currentReps.text = "0"
        progressImg.loadGif(name: "source")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
