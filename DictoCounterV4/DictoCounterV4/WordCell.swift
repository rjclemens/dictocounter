//
//  WordCell.swift
//  DictoCounter
//
//  Created by Raleigh Clemens on 3/20/21.
//

import UIKit


class WordCell: UICollectionViewCell {
    var wordName: UILabel!
    var wordCount: UILabel!
    var wordCellBox: UIView!
    
    var verticalPadding = CGFloat(5)
    var horizontalPadding = CGFloat(30)
    
    override init(frame: CGRect){
        super.init(frame: frame)
        let tan = UIColor(red: CGFloat(0.901), green: CGFloat(0.8117), blue: CGFloat(0.8117), alpha: CGFloat(0.75))
        let cellorange = UIColor(red: CGFloat(1), green: CGFloat(0.917), blue: CGFloat(0.803), alpha: CGFloat(0.75))
        
        wordName = UILabel()
        wordName.font = UIFont(name:"HelveticaNeue-Bold", size: 14.0)
        wordName.textColor = .black
        wordName.translatesAutoresizingMaskIntoConstraints = false
        wordName.backgroundColor = .clear
        contentView.addSubview(wordName)
        
        wordCount = UILabel()
        wordCount.font = UIFont(name:"HelveticaNeue-Bold", size: 14.0)
        wordCount.textColor = .black
        wordCount.translatesAutoresizingMaskIntoConstraints = false
        wordCount.backgroundColor = .clear
        contentView.addSubview(wordCount)
        
        wordCellBox = UIView()
        wordCellBox.translatesAutoresizingMaskIntoConstraints = false
        wordCellBox.backgroundColor = cellorange
        wordCellBox.layer.cornerRadius = 15.0
        contentView.addSubview(wordCellBox)
        
        setUpConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpConstraints(){
        NSLayoutConstraint.activate([
            wordCellBox.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            wordCellBox.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            wordCellBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wordCellBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                        
                                        
            wordName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
            wordName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalPadding),
            wordName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            wordName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3*horizontalPadding),
            
            wordCount.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
            wordCount.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalPadding),
            wordCount.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5*horizontalPadding),
            wordCount.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
        
                                        
        ])
    }
    
    func configure(word: Word){
        wordName.text = word.word
        wordCount.text = String(word.count)
    }
}

