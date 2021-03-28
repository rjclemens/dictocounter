//
//  WordCell.swift
//  DictoCounter
//
//  Created by Raleigh Clemens on 3/20/21.
//

import UIKit

protocol WordCellDelegate: class{
    func star(wasPressedOnCell cell: WordCell) //parameter: cell that was pressed
}

class WordCell: UICollectionViewCell {
    
    weak var delegate: WordCellDelegate?
    
    var wordName: UILabel!
    var wordCount: UILabel!
    var wordCellBox: UIView!
    
    var starButton: UIButton!
    var isStarred = false
    
    var starredTapAction: (()->())? //callback action
    
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
        
        starButton = UIButton()
        starButton.setImage(UIImage(named: "unfilled_star.png"), for: .normal)
        starButton.translatesAutoresizingMaskIntoConstraints = false
        starButton.addTarget(self, action: #selector(starred), for: .touchUpInside)
        contentView.addSubview(starButton)
        
        
        wordCellBox = UIView()
        wordCellBox.translatesAutoresizingMaskIntoConstraints = false
        wordCellBox.backgroundColor = cellorange
        wordCellBox.layer.cornerRadius = 15.0
        contentView.addSubview(wordCellBox)
        
        setUpConstraints()
        
    }
    
    @objc func starred(){
        print("touched")
        
        delegate?.star(wasPressedOnCell: self) //delegates the pressing reaction to the collection view
        
        //starredTapAction?() //chained back to main view controller
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.isUserInteractionEnabled else {return nil} //if user interaction is NOT enabled, return nil
        guard !self.isHidden else {return nil} //if hidden, return nil
        guard self.alpha >= 0.01 else {return nil}
        
        guard self.point(inside: point, with: event) else {return nil} //if the tap was not in the cell view, return nil
        //hence it didnt press the button
        
        
        if self.starButton.point(inside: convert(point, to: starButton), with: event){
            return self.starButton //return the starButton view if the pressed point was inside the starButton
            //says that starButton should be the receiver of this tap, instead of the collectionView
        }
        
        return super.hitTest(point, with: event)
        
    }
    
    
    func setUpConstraints(){
        NSLayoutConstraint.activate([
            wordCellBox.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            wordCellBox.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            wordCellBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wordCellBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                        
                                        
            wordName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1.1*verticalPadding),
            wordName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0.9*verticalPadding),
            wordName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            wordName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3*horizontalPadding),
            
            wordCount.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1.1*verticalPadding),
            wordCount.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0.9*verticalPadding),
            wordCount.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5*horizontalPadding),
            wordCount.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            
            starButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2.2*verticalPadding),
            starButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1.8*verticalPadding),
            starButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8*horizontalPadding),
            starButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4.5*horizontalPadding),
            
        
                                        
        ])
    }
    
    func configure(word: Word){
        wordName.text = word.word
        wordCount.text = String(word.count)
    }
}

