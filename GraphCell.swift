//
//  GraphCell.swift
//  Pods
//
//  Created by Raleigh Clemens on 3/31/21.
//

import UIKit
import Charts

class GraphCell: UICollectionViewCell {
    
    //var chartView = LineChartView()
    var graphCellBox: UIView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        contentView.backgroundColor = .blue
        
        //chartView.translatesAutoresizingMaskIntoConstraints = false
        //contentView.addSubview(chartView)
        
        graphCellBox = UIView()
        graphCellBox.translatesAutoresizingMaskIntoConstraints = false
        //graphCellBox.backgroundColor = cellorange
        graphCellBox.layer.cornerRadius = 15.0
        contentView.addSubview(graphCellBox)
        
        setUpConstraints()
    }
    
    func setUpConstraints(){
        NSLayoutConstraint.activate([
            graphCellBox.topAnchor.constraint(equalTo: contentView.topAnchor),
            graphCellBox.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            graphCellBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            graphCellBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(graph: ChartViewBase){
        //pass the configured graph into graphCellBox and set it up inside configure
        graph.translatesAutoresizingMaskIntoConstraints = false
        graphCellBox.addSubview(graph)
        
        NSLayoutConstraint.activate([
            graph.topAnchor.constraint(equalTo: graphCellBox.topAnchor),
            graph.bottomAnchor.constraint(equalTo: graphCellBox.bottomAnchor),
            graph.leadingAnchor.constraint(equalTo: graphCellBox.leadingAnchor),
            graph.trailingAnchor.constraint(equalTo: graphCellBox.trailingAnchor),
            
        ])
    }
}
