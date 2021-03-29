//
//  ViewController.swift
//  DictoCounter
//
//  Created by Raleigh Clemens on 3/20/21.
//

import UIKit
import Speech
import os.log

//data storing vars
var wordsDict = [String:Word]()
var sortedWordsDict = [(String,Word)]() //sorting wordsDict returns tuple array
var allWords = [Word]()
var tempWords = [Word]()

//collection view
var wordCellReuseID = "wordcell"
var wordsColl: UICollectionView!
var tabChanger: UIView!
let padding = CGFloat(10)


//buttons
var homeButton: UIButton!
var graphButton: UIButton!

let numWords = 100

//searching initializers
var searchBarPressed = false
var wordsSearch = UISearchBar()


//colors
let lightblue = UIColor(red: CGFloat(0.545), green: CGFloat(0.851), blue: CGFloat(0.925), alpha: CGFloat(0.55))
let backorange = UIColor(red: CGFloat(1), green: CGFloat(0.690), blue: CGFloat(0.227), alpha: CGFloat(1))
let cellorange = UIColor(red: CGFloat(0.901), green: CGFloat(0.8117), blue: CGFloat(0.8117), alpha: CGFloat(0.75))
let taborange = UIColor(red: CGFloat(1), green: CGFloat(0.9607), blue: CGFloat(0.8509), alpha: CGFloat(1))


//boolean extension
extension Bool{
    var boolValue: Int{self ? 1:0} //assigns 1 if self- the bool being referenced- is true; else 0 if false
}


class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //deleteAllData()
        
        //load the previous data into allWords
        if let loadData = loadWords(){
            allWords = loadData
        }
        
        addWordListToDictionary(words: allWords)
        tempWords = Array(allWords.prefix(numWords)) //only show first 50 words
        
        view.backgroundColor = .white
        
        let speechRecognizer = SFSpeechRecognizer()
        requestDictAccess();
        
        if speechRecognizer!.isAvailable { //if the user has granted permission
            speechRecognizer?.supportsOnDeviceRecognition = true //for offline data
            
            recognizeAudioStream()
        }
        
        setUpViews()
        setUpConstraints()
        wordsColl.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        wordsColl.reloadData()
        
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
        wordsSearch.placeholder = "Search for a word..."
        wordsSearch.prompt = "Yes, we're stealing your data! ;)"
        wordsSearch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wordsSearch)
        
        tabChanger = UIView(frame: .zero)
        tabChanger.translatesAutoresizingMaskIntoConstraints = false
        tabChanger.backgroundColor = taborange
        view.addSubview(tabChanger)
        
        
        homeButton = UIButton()
        homeButton.setImage(UIImage(named: "unfilled_star.png"), for: .normal)
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        homeButton.addTarget(self, action: #selector(goToHome), for: .touchUpInside)
        tabChanger.addSubview(homeButton)
        
        graphButton = UIButton()
        graphButton.setImage(UIImage(named: "filled_star.png"), for: .normal)
        graphButton.translatesAutoresizingMaskIntoConstraints = false
        graphButton.addTarget(self, action: #selector(goToGraph), for: .touchUpInside)
        tabChanger.addSubview(graphButton)
        

    }
    
    func setUpConstraints(){
        NSLayoutConstraint.activate([
            wordsColl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 95),
            wordsColl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            wordsColl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            wordsColl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            tabChanger.topAnchor.constraint(equalTo: wordsColl.bottomAnchor),
            tabChanger.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabChanger.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tabChanger.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            homeButton.topAnchor.constraint(equalTo: tabChanger.topAnchor, constant: padding/2),
            homeButton.bottomAnchor.constraint(equalTo: tabChanger.bottomAnchor, constant: -padding/2),
            homeButton.leadingAnchor.constraint(equalTo: tabChanger.leadingAnchor, constant: padding*3),
            homeButton.trailingAnchor.constraint(equalTo: tabChanger.trailingAnchor, constant: -34*padding),
            
            graphButton.topAnchor.constraint(equalTo: tabChanger.topAnchor, constant: padding/2),
            graphButton.bottomAnchor.constraint(equalTo: tabChanger.bottomAnchor, constant: -padding/2),
            graphButton.leadingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: padding*4),
            graphButton.trailingAnchor.constraint(equalTo: tabChanger.trailingAnchor, constant: -25*padding),
            
            
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
                    self.populateTempWords()
                    
                    wordsColl.reloadData()
//
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
    
    //sorts based first on whether word is pinned (true first, false last), and then on the count of the word.
    func sortDictionaryPinned() -> [(String, Word)]{
            
        return wordsDict.sorted (by: {
            return ($0.value.pinned.boolValue, $0.value.count) > ($1.value.pinned.boolValue, $1.value.count)
        })
        
    }
    
    func populateTempWords(){
        sortedWordsDict = self.sortDictionaryPinned()
        
        allWords = [] //reset the array to reload words
        
        for (wordKey, wordObj) in sortedWordsDict{
            allWords.append(wordObj)
        }
        
        self.saveWords() //saves allWords list to file
        
        tempWords = Array(allWords.prefix(numWords)) //only show first 50 words
        print(tempWords)
    }
    
    
    func addToDictionary(wordNames:[String]?){
        if let wordNames = wordNames{
            for wordName in wordNames{
                var fixedWordName = wordName.lowercased()
                
                fixedWordName.removeAll(where: {$0.isPunctuation}) //get rid of all punctuation
                
                let word = wordsDict[fixedWordName]
                if word != nil{ //if the key already exists, add one to the value's .count field
                    
                    wordsDict.updateValue(Word(word: fixedWordName, count: word!.count + 1, pinned: word!.pinned), forKey: fixedWordName)
                }
                else{
                    wordsDict[fixedWordName] = Word(word: fixedWordName, count: 1, pinned: false) //else create the key with word.count value 1
                }
            }
        }
    }
    
    func addWordListToDictionary(words: [Word]?){
        if let words = words{
            for word in words{
                let fixedWordName = word.word.lowercased()
                
                if wordsDict[fixedWordName] != nil{ //if the key already exists, add the stored value to the current value
                    wordsDict.updateValue(Word(word: fixedWordName, count: wordsDict[fixedWordName]!.count + word.count, pinned: word.pinned), forKey: fixedWordName)
                }
                else{
                    wordsDict[fixedWordName] = Word(word: fixedWordName, count: word.count, pinned: word.pinned) //else create the key with the stored value
                }
            }
        }
    }
    
    
    @objc func goToHome(){
        let homeView = ViewController()
        navigationController?.pushViewController(homeView, animated: true)
    }
    
    @objc func goToGraph(){
        print("pressed")
        let graphView = GraphViewController()
        navigationController?.pushViewController(graphView, animated: true)
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
    
    private func deleteAllData(){
        do{
            try FileManager.default.removeItem(at: Word.ArchiveURL)
        }
        catch{
            print("could not remove data.")
        }
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
        
        wordCell.delegate = self
        
        wordCell.configure(word: tempWords[indexPath.item])
        return wordCell
    }
    
}

extension ViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        print(searchBar.text!)
        
        loadSearchResults(text: searchBar.text!.lowercased())
        wordsColl.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        tempWords = Array(allWords.prefix(numWords)) //only show first 50 words
        wordsColl.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        searchBar.showsCancelButton = true
        loadSearchResults(text: searchBar.text!.lowercased())
        wordsColl.reloadData()
    }
    
    func loadSearchResults(text: String){
        tempWords.removeAll()
        
        for word in allWords{
            if word.word.lowercased().contains(text){
                tempWords.append(word)
            }
        }
    }
    
}


extension ViewController: WordCellDelegate{
    func star(wasPressedOnCell: WordCell){
        print("touched")
        
        if(wasPressedOnCell.isStarred){ //if the button has already been starred, unstar it
            wasPressedOnCell.starButton.setImage(UIImage(named: "unfilled_star.png"), for: .normal)
            wasPressedOnCell.isStarred = false
            wordsDict[wasPressedOnCell.wordName.text!]!.pinned = false //set the pinned value to true

        }
        
        else{ //else, star the button
            wasPressedOnCell.starButton.setImage(UIImage(named: "filled_star.png"), for: .normal)
            wasPressedOnCell.isStarred = true
            wordsDict[wasPressedOnCell.wordName.text!]!.pinned = true //set the pinned value to true

        }
        
        populateTempWords()
        wordsColl.reloadData()
    }
}
