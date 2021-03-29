//
//  GraphViewController.swift
//  DictoCounter
//
//  Created by Raleigh Clemens on 3/27/21.
//

import UIKit
import Charts
import TinyConstraints

class GraphViewController: UIViewController {

    
    //lazy var only calculated when called
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBlue
        return chartView
    }()
    
    var homeViewController: ViewController = ViewController()
    
    let dataPts = 100
    var yValues: [ChartDataEntry] = []
    var allWordsNoPins: [Word] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        
        assignData()
        setData()
        
    }
    
    
    func setData(){
        let set1 = LineChartDataSet(entries: yValues, label: "stuff")
        let data = LineChartData(dataSet: set1)
        lineChartView.data = data
    }
    
    func assignData(){
        setUpTempWords()
        
        let dataValues = allWordsNoPins
        print(allWordsNoPins.count)
        
        for i in 0...dataPts-1{
            yValues.append(ChartDataEntry(x: Double(i), y: Double(dataValues[i].count)))
        }
        
    }
    
    func setUpTempWords(){
        let sortedWordsDictNoPins = sortDictionaryWithoutPins()
        for (_, word) in sortedWordsDictNoPins{
            allWordsNoPins.append(word)
            
            if allWordsNoPins.count > dataPts{ //append only first specified # of words
                break
            }
        }
    }
    
    func sortDictionaryWithoutPins() -> [(String, Word)]{
        return wordsDict.sorted(by: {
            return $0.value.count > $1.value.count
        })
    }
}

extension GraphViewController: ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
}
