//
//  ViewController.swift
//  DictoCounter
//
//  Created by Raleigh Clemens on 3/20/21.
//

import UIKit
import Speech
import os.log

var wordsDict = [String:Int]()
var sortedWordsDict = [(String, Int)]()
var wordCellReuseID = "wordcell"
var wordsColl: UICollectionView!
var allWords = [Word]()
var tempWords = [Word]()
let padding = CGFloat(10)

var searchBarPressed = false

var wordsSearch = UISearchBar()


let lightblue = UIColor(red: CGFloat(0.545), green: CGFloat(0.851), blue: CGFloat(0.925), alpha: CGFloat(0.55))
let backorange = UIColor(red: CGFloat(1), green: CGFloat(0.690), blue: CGFloat(0.227), alpha: CGFloat(1))
let cellorange = UIColor(red: CGFloat(0.901), green: CGFloat(0.8117), blue: CGFloat(0.8117), alpha: CGFloat(0.75))

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load the previous data into allWords
        if let loadData = loadWords(){
            allWords = loadData
        }
        
        addWordListToDictionary(words: allWords)
        tempWords = allWords
        
        setUpViews()
        setUpConstraints()
        wordsColl.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        wordsColl.reloadData()
        let speechRecognizer = SFSpeechRecognizer()
        requestDictAccess();
        
        if speechRecognizer!.isAvailable { //if the user has granted permission
            speechRecognizer?.supportsOnDeviceRecognition = true //for offline data
            
            recognizeAudioStream()
        }
        
    }
    
    func setUpViews(){
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = padding/3.2
        layout.scrollDirection = .vertical
        
        wordsColl = UICollectionView(frame: .zero, collectionViewLayout: layout)
        wordsColl.translatesAutoresizingMaskIntoConstraints = false
        wordsColl.dataSource = self
        wordsColl.delegate = self
        
        wordsColl.register(WordCell.self, forCellWithReuseIdentifier: wordCellReuseID)
        wordsColl.backgroundColor = backorange

        view.addSubview(wordsColl)
        
        wordsSearch = UISearchBar(frame: .zero)
        wordsSearch.delegate = self
        wordsSearch.placeholder = "Search For a Word ;)"
        wordsSearch.prompt = "We're stealing your data."
        wordsSearch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wordsSearch)
        

    }
    
    func setUpConstraints(){
        NSLayoutConstraint.activate([
            wordsColl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 95),
            wordsColl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            wordsColl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            wordsColl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            wordsSearch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            wordsSearch.bottomAnchor.constraint(equalTo: wordsColl.topAnchor, constant: -20),
            wordsSearch.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            wordsSearch.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    
    
    //dictation functions
    func requestDictAccess(){
        let speechRecognizer = SFSpeechRecognizer()
        speechRecognizer?.delegate = self //the viewController acts on behalf of SpeechRecognizer
        
        SFSpeechRecognizer.requestAuthorization{ authStatus in
            switch authStatus{
            case .notDetermined:
                print("not determined")
            case .restricted:
                print("restricted")
            case .denied:
                print("denied")
            case .authorized:
                print("authorized")
            default:
                print("unknown case")
            }
        }
    }

    
    func recognizeAudioStream() {
        let speechRecognizer = SFSpeechRecognizer()
        
        //performs speech recognition on live audio; as audio is captured, call append
        //to request object, call endAudio() to end speech recognition
        var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        
        //determines & edits state of speech recognition task (end, start, cancel, etc)
        var recognitionTask: SFSpeechRecognitionTask?
        
        let audioEngine = AVAudioEngine()
        
        
        func startRecording() throws{
            
            //cancel previous audio task
            recognitionTask?.cancel()
            recognitionTask = nil
            
            //get info from microphone
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let inputNode = audioEngine.inputNode
            
            //audio buffer; takes a continuous input of audio and recognizes speech
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            //allows device to print results of your speech before you're done talking
            recognitionRequest?.shouldReportPartialResults = true
            
            
            recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest!) {result, error in
                
                var isFinal = false
                
                if let result = result{ //if we can let result be the nonoptional version of result, then
                    isFinal = result.isFinal
                    print("Text: \(result.bestTranscription.formattedString)")
                    
                }
                
                if error != nil || result!.isFinal{ //if an error occurs or we're done speaking
                    
                    audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    recognitionTask = nil
                    recognitionRequest = nil

                    let bufferText = result?.bestTranscription.formattedString.components(separatedBy: (" "))
                    print("completed buffer")
                    
                    self.addToDictionary(wordNames: bufferText)
                    
                    sortedWordsDict = wordsDict.sorted {
                        return $0.value > $1.value
                    }
                    
                    allWords = [] //reset the array to reload words
                    
                    for (wordKey, countValue) in sortedWordsDict{
                        allWords.append(Word(word: wordKey, count: countValue))
                    }
                    
                    self.saveWords() //saves allWords list to file
                    tempWords = allWords
                    
                    wordsColl.reloadData()
                    
                    do{
                        try startRecording()
                    }
                    catch{
                        print(error)
                    }
                    
                }
            
            }
            
            //configure microphone; let the recording format match with that of the bus we are using
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            //contents of buffer will be dumped into recognitionRequest and into result, where
            //it will then be transcribed and printed out
            //1024 bytes = dumping "limit": once buffer fills to 1024 bytes, it is appended to recognitionRequest
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
        }
        
        do{
            try startRecording()
        }
        catch{
            print(error)
        }
        
        
    }
    
    func addToDictionary(wordNames:[String]?){
        if let wordNames = wordNames{
            for wordName in wordNames{
                wordName.removeAll(where: {$0.isPunctuation})
                if wordsDict[wordName.lowercased()] != nil{ //if the key already exists, add one to it
                    wordsDict.updateValue(wordsDict[wordName.lowercased()]! + 1, forKey: wordName)
                }
                else{
                    wordsDict[wordName.lowercased()] = 1 //else create the key with value 1
                }
            }
        }
    }
    
    func addWordListToDictionary(words: [Word]?){
        if let words = words{
            for word in words{
                if wordsDict[word.word.lowercased()] != nil{ //if the key already exists, add one to it
                    wordsDict.updateValue(wordsDict[word.word.lowercased()]! + word.count, forKey: word.word)
                }
                else{
                    wordsDict[word.word.lowercased()] = 1 //else create the key with value 1
                }
            }
        }
    }
    
    //MARK- private methods
    //save and load data whenever change happens
    private func saveWords(){
        
        //attempts to save allWords Word array to the URL path (where data is saved for the app in the iPhone
        //returns true if the save is successful, false otherwise
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(allWords, toFile: Word.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Words successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save words...", log: OSLog.default, type: .error)
        }
        
    }
    
    private func loadWords() -> [Word]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Word.ArchiveURL.path) as? [Word]
        
        //as? allows the return statement to take on value nil in case the downcast to Word
        //doesn't work
    }
    
    
}



extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        //collectionView.frame.height -
        
        let size = 5*padding
        let sizeWidth = collectionView.frame.width - padding/1.5
        return CGSize(width: sizeWidth, height: size)
    }
}



extension ViewController: UICollectionViewDataSource{
    
    //collection functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tempWords.count //total number of entries
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let wordCell = collectionView.dequeueReusableCell(withReuseIdentifier: wordCellReuseID, for: indexPath) as! WordCell
        
        wordCell.configure(word: tempWords[indexPath.item])
        return wordCell
    }
    
}

extension ViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        print(searchBar.text!)
        tempWords.removeAll()
        
        for word in allWords{
            if word.word.lowercased().contains(searchBar.text!.lowercased()){
                tempWords.append(word)
            }
        }
        
        wordsColl.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        tempWords = allWords
        wordsColl.reloadData()
    }
}
