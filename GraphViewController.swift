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
    lazy var lineChartViewZipf: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBlue
        chartView.rightAxis.enabled = false //right axis contributes nothing
        
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.setLabelCount(6, force: false)
        xAxis.labelTextColor = .white
        xAxis.axisLineColor = .systemBlue
        
        chartView.animate(xAxisDuration: 1)
        
        return chartView
    }()
    
    //lazy var only calculated when called
    lazy var lineChartViewZipfScaled: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBlue
        chartView.rightAxis.enabled = false //right axis contributes nothing
        
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.setLabelCount(6, force: false)
        xAxis.labelTextColor = .white
        xAxis.axisLineColor = .systemBlue
        
        chartView.animate(xAxisDuration: 1)
        
        return chartView
    }()
    
    lazy var pieChartView: PieChartView = {
        let pieChart = PieChartView()
        pieChart.backgroundColor = .systemBlue
        
        return pieChart
    }()
    
    var graphColl: UICollectionView!
    var viewTitle: UILabel!
    var linegraphs: [LineChartView] = []
    var piegraphs: [PieChartView] = []
    var graphs: [ChartViewBase] = []
    var graphReuseID = "graph"
    
    let dataPts = 75
    let pieDataPts = 8
    var yValues: [ChartDataEntry] = []
    var yValuesScaled: [ChartDataEntry] = []
    var pieDataEntries: [PieChartDataEntry] = []
    var xValuesPie: [String] = []
    var allWordsNoPins: [Word] = []
    var points = Array(repeating: Array(repeating: 0.0, count: 2), count: 75)
    var regressedValues: [ChartDataEntry] = []
    var learningRate = 0.001
    var numIterations = 15000
    var realDataPts = -1
    
    let bkgrdColor = UIColor(red: CGFloat(192/255), green: CGFloat(219/255), blue: CGFloat(220/266), alpha: CGFloat(1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setUpViews()
        setUpGraphs()
        setUpConstraints()
        
    }
    
    
    func setUpViews(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = padding/3.2
        layout.scrollDirection = .vertical
        
        graphColl = UICollectionView(frame: .zero, collectionViewLayout: layout)
        graphColl.translatesAutoresizingMaskIntoConstraints = false
        graphColl.dataSource = self
        graphColl.delegate = self
        
        //must register GraphCell class before calling dequeueReusableCell
        graphColl.register(GraphCell.self, forCellWithReuseIdentifier: graphReuseID)
        
        graphColl.backgroundColor = bkgrdColor
        view.addSubview(graphColl)
        
        viewTitle = UILabel()
        viewTitle.text = "Graphs"
        viewTitle.translatesAutoresizingMaskIntoConstraints = false
        viewTitle.backgroundColor = bkgrdColor
        view.addSubview(viewTitle)
        
    }
    
    func setUpGraphs(){
        
        assignDataZipf()
        setDataZipf()
        linegraphs.append(lineChartViewZipf)
        
        assignDataZipfScaled()
        setDataZipfScaled()
        linegraphs.append(lineChartViewZipfScaled)
        
        assignPieChart()
        setPieChart()
        piegraphs.append(pieChartView)
        
        graphs = linegraphs + piegraphs
        
    }
    
    func setUpConstraints(){
        NSLayoutConstraint.activate([
//            viewTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            viewTitle.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
//            viewTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            viewTitle.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            graphColl.topAnchor.constraint(equalTo: viewTitle.bottomAnchor),
            graphColl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            graphColl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            graphColl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    
    //zipf unscaled
    func setDataZipf(){
        let set1 = LineChartDataSet(entries: yValues, label: "Word Frequency")
        let data = LineChartData(dataSet: set1)
        
        set1.drawCirclesEnabled = true
        set1.circleRadius = 3
        set1.mode = .cubicBezier //smoothes out curve
        set1.setColor(.white)
        set1.lineWidth = 3
        set1.drawHorizontalHighlightIndicatorEnabled = false //ugly yellow line
        
        data.setDrawValues(false)

        lineChartViewZipf.data = data
    }
    
    func assignPieChart(){
        setUpTempWords()
        
        for i in 0..<pieDataPts {
            pieDataEntries.append(PieChartDataEntry(value: Double(allWordsNoPins[i].count), label: allWordsNoPins[i].word))
            xValuesPie.append(allWordsNoPins[i].word)
        }
        
    }
    
    func setPieChart(){
        let pieChartDataSet = PieChartDataSet(entries: pieDataEntries)
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
            
        for _ in 0..<pieDataPts {
          let red = Double(arc4random_uniform(200))
          let green = Double(arc4random_uniform(200))
          let blue = Double(arc4random_uniform(200))
            
          let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
          colors.append(color)
        }
        pieChartDataSet.colors = colors
    }

    func assignDataZipf(){
        setUpTempWords()
        
        for i in 0...realDataPts-1{
            yValues.append(ChartDataEntry(x: Double(i), y: Double(allWordsNoPins[i].count)))
        }
        
    }
    
    func setDataZipfScaled(){
        let set1 = LineChartDataSet(entries: yValuesScaled, label: "LOG(Word Frequency)")
        
        //linear regression set
        let set2 = LineChartDataSet(entries: regressedValues, label: "Linear Regression")
        
        
        let data = LineChartData()
        data.addDataSet(set1)
        data.addDataSet(set2)
        
        set1.drawCirclesEnabled = true
        set1.circleRadius = 3
        set1.setColor(.white)
        set1.lineWidth = 0
        set1.drawHorizontalHighlightIndicatorEnabled = false //ugly yellow line
        
        set2.drawCirclesEnabled = true
        set2.circleRadius = 0
        set2.setColor(.red)
        set2.lineWidth = 4
        set2.drawHorizontalHighlightIndicatorEnabled = false
        
        data.setDrawValues(false)

        lineChartViewZipfScaled.data = data
    }
    
    func assignDataZipfScaled(){
        //setUpTempWords() already done in nonscaled version
        
        for i in 0...realDataPts-1{
            yValuesScaled.append(ChartDataEntry(x: Double(i), y: log10(Double(allWordsNoPins[i].count))))
            points[i][0] = Double(i)
            points[i][1] = log10(Double(allWordsNoPins[i].count)) //word count
        }
        
        
        let guess_m = 0.0
        let guess_b = 0.0
        
        let regressionValues = LinearRegression.descent(points: points, starting_m: guess_m, starting_b: guess_b, learningRate: learningRate, numIterations: numIterations)
        
        print(regressionValues[0], regressionValues[1])
        
        for i in 0...realDataPts-1{
            regressedValues.append(ChartDataEntry(x: Double(i), y: regressionValues[0]*Double(i) + regressionValues[1]))
            //data set: (x, mx+b)
        }
        
        
    }
    
    
    
    //sorting and collecting data methods
    func setUpTempWords(){
        let sortedWordsDictNoPins = sortDictionaryWithoutPins()
        for (_, word) in sortedWordsDictNoPins{
            allWordsNoPins.append(word)
            
            if allWordsNoPins.count > dataPts{ //append only first specified # of words
                break
            }
        }
        
        let dataValuesCount = allWordsNoPins.count
        realDataPts = (dataValuesCount > dataPts) ? dataPts : dataValuesCount //in case we dont have 75 words
        
    }
    
    func sortDictionaryWithoutPins() -> [(String, Word)]{
        return wordsDict.sorted(by: {
            return $0.value.count > $1.value.count
        })
    }
    
}


extension GraphViewController: ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("ENTRYY: ", entry)
    }
}

extension GraphViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        //collectionView.frame.height -
        
        let size = 25*padding
        let sizeWidth = collectionView.frame.width - padding/3
        return CGSize(width: sizeWidth, height: size)
    }
    
}

extension GraphViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return linegraphs.count + piegraphs.count //total number of graphs
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let graphColl = collectionView.dequeueReusableCell(withReuseIdentifier: graphReuseID, for: indexPath) as! GraphCell
        
        graphColl.configure(graph: graphs[indexPath.item])
        return graphColl
    }
}
