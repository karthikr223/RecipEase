//
//  DessertViewController.swift
//  Fetch iOS Coding Challenge
//
//  Created by Karthik Rajagopalan on 4/9/23.
//

import UIKit

///A view controller that displays a preview image, ingredients, measures and instructions for some selected dessert.
class DetailViewController: UIViewController, UIScrollViewDelegate {
    var marginX = CGFloat(20)
    
    var dessert = Dessert()
    var details: DessertDetails?
    var dessertDescription: String?
    
    var topBar = UIView()
    var topBarSeparator = UIView()
    var closeButton = UIButton()
        
    var image: UIImage?
    var imageView = UIImageView()
    var backgroundView = UIView()
    
    var scrollView = UIScrollView()
    var contentView = UIView()
    
    var titleHeading = UILabel()
    var descriptionSubHeading = UILabel()
    var descriptionDisplay = UITextView()
    var ingredientsSubHeading = UILabel()
    var ingredientsDisplay = UITextView()
    var instructionsSubheading = UILabel()
    var instructionsDisplay = UITextView()
    var divider1 = UIView()
    var divider2 = UIView()
    var divider3 = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///fetch the dessert's details (instructions, ingredients, measures) using the given API endpoint and saves it to the dessert object. If details have been fetched already, just retrieves it from the dessert.details field.
        dessert.getDetails { (details) in
            self.details = details
            DispatchQueue.main.async {
                self.setupDetailsView()
            }
        }
        
        ///get the description of the dessert. If not already generated, calls the ChatGPT API.
        dessert.getGPTDescription { (description) in
            self.dessertDescription = description
            DispatchQueue.main.async {
                self.setupDetailsView()
            }
        }
        
        setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        setupView()
    }
    
    func setupView(){
        self.view.backgroundColor = .clear
        setupDetailsView()
    }
    
    func setupDetailsView(){
        guard details != nil else {
            return
        }
        
        setupImageView()
        setupScrollView()
        setupTopBar()
    }
    
    ///Top bar containing a close button. It is invisible when the user is scrolled all the way to the top, and fades in as the user scrolls down.
    func setupTopBar(){
        topBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        topBar.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        setTopBarOpacity()
        topBarSeparator.frame = CGRect(x: 0, y: topBar.frame.height, width: topBar.frame.width, height: 1)
        topBarSeparator.backgroundColor = UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1)
        topBar.addSubview(topBarSeparator)
        self.view.addSubview(topBar)

        closeButton.frame = CGRect(x: view.safeAreaInsets.left + 20, y: 0, width: 20, height: 20)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.imageView?.tintColor = UIColor(red: 232/255, green: 63/255, blue: 70/255, alpha: 1)
        closeButton.center.y = topBar.frame.height/2
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        topBar.addSubview(closeButton)
    }
    
    ///An image view that displays the thumbnail image for the selected dessert.
    func setupImageView(){
        guard let url = URL(string: dessert.thumbnailURL) else {
            return
        }
        //fetch the image from the image cache
        if image == nil {
            ImageCache.shared.getImage(url: url) { image in
                self.image = image
                DispatchQueue.main.async {
                    self.setupDetailsView()
                }
            }
        }
        //display the image in the image view
        if let thumbnail = image {
            let imageSize = thumbnail.size
            let sideRatio = imageSize.height/imageSize.width
            imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width * sideRatio)
            imageView.image = thumbnail
            self.view.addSubview(imageView)
        }
        
        backgroundView.backgroundColor = .white
        backgroundView.frame = CGRect(x: 0, y: imageView.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.imageView.frame.maxY)
        self.view.addSubview(backgroundView)
    }
    
    ///Main scroll view that contains the body text for the dessert (description, ingredients, instructions).
    func setupScrollView(){
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.delegate = self
        scrollView.layer.masksToBounds = false
        setupContentView()
        
        contentView.frame = CGRect(x: 0, y: imageView.frame.maxY, width: scrollView.frame.width, height: instructionsDisplay.frame.maxY + 500)
        contentView.backgroundColor = .white
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: max(instructionsDisplay.frame.maxY + contentView.frame.minY + 20, 20 + self.view.frame.height))
        scrollView.addSubview(contentView)
        self.view.addSubview(scrollView)
        self.view.bringSubviewToFront(scrollView)
    }
    
    ///A view that displays:
    ///1. A description of the dessert
    ///2.  The ingredients and their respective measures,
    ///3. The instructions.
    func setupContentView(){
        titleHeading.text = dessert.name
        titleHeading.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        titleHeading.numberOfLines = 0
        titleHeading.frame = CGRect(x: view.safeAreaInsets.left + marginX, y: 20, width: self.view.frame.width - (view.safeAreaInsets.left + view.safeAreaInsets.right + 2 * 20), height: titleHeading.intrinsicContentSize.height)
        let titleHeadingContentSize = titleHeading.sizeThatFits(CGSize(width: titleHeading.frame.width, height: CGFloat.greatestFiniteMagnitude))
        titleHeading.frame.size = CGSize(width: titleHeading.frame.width, height: titleHeadingContentSize.height)
        titleHeading.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        contentView.addSubview(titleHeading)
        
        divider1.frame = CGRect(x: 0, y: titleHeading.frame.maxY + 10, width: self.view.frame.width, height: 1)
        divider1.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        contentView.addSubview(divider1)
        
        descriptionSubHeading.text = "Description"
        descriptionSubHeading.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        descriptionSubHeading.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        descriptionSubHeading.frame =  CGRect(x: view.safeAreaInsets.left + marginX, y: divider1.frame.maxY + 10, width: descriptionSubHeading.intrinsicContentSize.width, height: descriptionSubHeading.intrinsicContentSize.height)
        contentView.addSubview(descriptionSubHeading)
        
        descriptionDisplay.isUserInteractionEnabled = false
        descriptionDisplay.isScrollEnabled = false
        descriptionDisplay.text = dessertDescription
        descriptionDisplay.font = UIFont.systemFont(ofSize: 15)
        descriptionDisplay.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1)
        descriptionDisplay.frame = CGRect(x: view.safeAreaInsets.left + marginX, y: descriptionSubHeading.frame.maxY + 5, width: self.scrollView.frame.width - (view.safeAreaInsets.left + view.safeAreaInsets.right + 2 * marginX), height: 100)
        let descriptionDisplayContentSize = descriptionDisplay.sizeThatFits(CGSize(width: descriptionDisplay.frame.width, height: CGFloat.greatestFiniteMagnitude))
        descriptionDisplay.frame.size = CGSize(width: descriptionDisplay.frame.width, height: descriptionDisplayContentSize.height)
        contentView.addSubview(descriptionDisplay)
        
        divider2.frame = CGRect(x: 0, y: descriptionDisplay.frame.maxY + 10, width: self.view.frame.width, height: 1)
        divider2.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        contentView.addSubview(divider2)
        
        ingredientsSubHeading.text = "Ingredients"
        ingredientsSubHeading.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        ingredientsSubHeading.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        ingredientsSubHeading.frame =  CGRect(x: view.safeAreaInsets.left + marginX, y: divider2.frame.maxY + 10, width: ingredientsSubHeading.intrinsicContentSize.width, height: ingredientsSubHeading.intrinsicContentSize.height)
        contentView.addSubview(ingredientsSubHeading)
        
        ingredientsDisplay.isUserInteractionEnabled = false
        ingredientsDisplay.isScrollEnabled = false
        ingredientsDisplay.text = details?.ingredients.map({ "•\t\($0.ingredient.capitalizingFirstLetter()) (\($0.measure))"}).joined(separator: "\n")
        ingredientsDisplay.font = UIFont.systemFont(ofSize: 15)
        ingredientsDisplay.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1)
        ingredientsDisplay.frame = CGRect(x: view.safeAreaInsets.left + marginX, y: ingredientsSubHeading.frame.maxY + 5, width: self.scrollView.frame.width - (view.safeAreaInsets.left + view.safeAreaInsets.right + 2 * marginX), height: 100)
        let ingredientsDisplayContentSize = ingredientsDisplay.sizeThatFits(CGSize(width: ingredientsDisplay.frame.width, height: CGFloat.greatestFiniteMagnitude))
        ingredientsDisplay.frame.size = CGSize(width: ingredientsDisplay.frame.width, height: ingredientsDisplayContentSize.height)
        contentView.addSubview(ingredientsDisplay)
        
        divider3.frame = CGRect(x: 0, y: ingredientsDisplay.frame.maxY + 10, width: self.view.frame.width, height: 1)
        divider3.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        contentView.addSubview(divider3)
        
        instructionsSubheading.text = "Instructions"
        instructionsSubheading.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        instructionsSubheading.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        instructionsSubheading.frame =  CGRect(x: view.safeAreaInsets.left + marginX, y: divider3.frame.maxY + 10, width: instructionsSubheading.intrinsicContentSize.width, height: instructionsSubheading.intrinsicContentSize.height)
        contentView.addSubview(instructionsSubheading)
        
        instructionsDisplay.isUserInteractionEnabled = false
        instructionsDisplay.isScrollEnabled = false
        instructionsDisplay.text = details?.instructions
        instructionsDisplay.font = UIFont.systemFont(ofSize: 15)
        instructionsDisplay.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1)
        instructionsDisplay.frame = CGRect(x: view.safeAreaInsets.left + marginX, y: instructionsSubheading.frame.maxY + 5, width: self.scrollView.frame.width - (view.safeAreaInsets.left + view.safeAreaInsets.right + 2 * marginX), height: 100)
        let instructionsDisplayContentSize = instructionsDisplay.sizeThatFits(CGSize(width: instructionsDisplay.frame.width, height: CGFloat.greatestFiniteMagnitude))
        instructionsDisplay.frame.size = CGSize(width: instructionsDisplay.frame.width, height: instructionsDisplayContentSize.height)
        contentView.addSubview(instructionsDisplay)
    }
    
    ///Modify top bar opacity as the user scrolls
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setTopBarOpacity()
    }
    
    ///The opacity of the top bar is changed (from 0 - 0.99) as the user scrolls down, past the top image.
    func setTopBarOpacity(){
        let maxAlphaPosition = imageView.frame.height - topBar.frame.height
        let minAlphaPosition = imageView.frame.height - topBar.frame.height - 30
        
        if(scrollView.contentOffset.y < minAlphaPosition){
            topBar.alpha = 0
        }
        else if (scrollView.contentOffset.y > maxAlphaPosition){
            topBar.alpha = 0.99
        }
        else {
            topBar.alpha = 0.99 * (scrollView.contentOffset.y - minAlphaPosition)/(maxAlphaPosition - minAlphaPosition)
        }
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
