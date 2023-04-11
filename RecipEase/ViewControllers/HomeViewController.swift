//
//  ViewController.swift
//  Fetch iOS Coding Challenge
//
//  Created by Karthik Rajagopalan on 4/9/23.
//

import UIKit

///The home view controller of the app. Displays the entire list of desserts in a table view, fetched using the dessert list endpoint.
class HomeViewController: UIViewController {
    
    //loading view
    var loadingView = UIView()
    var loadingHeadingLabel = UILabel()
    var loadingSubheadingLabel = UILabel()
    var progressBar = UIProgressView()
    var progressDescription = UILabel()
    
    //main view
    var titleLabel = UILabel()
    var searchBar = UISearchBar()
    var tableView = UITableView()
    
    var desserts: [Dessert] = []
    var displayedDesserts: [Dessert] = []
    
    var areDescriptionsLoaded = false
    var numDescriptionsLoaded = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        fetchDesserts()
        setupView()
    }
    

    func setupView(){
        if(areDescriptionsLoaded){
            setupMainView()
        }
        else {
            setupLoadingView()
        }
    }
    
    ///A loading screen that is displayed when the app is initially opened, while waiting for descriptions to be generated by ChatGPT for each dessert. The progress bar tracks the loading progress.
    func setupLoadingView(){
        loadingView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(loadingView)
        
        progressBar.frame = CGRect(x: 0, y: loadingSubheadingLabel.frame.maxY + 20, width: self.view.frame.width * 2/3, height: 10)
        progressBar.frame.size = CGSize(width: self.view.frame.width * 2/3, height: 10)
        progressBar.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        progressBar.progressTintColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1)
        loadingView.addSubview(progressBar)
        
        loadingSubheadingLabel.text = "Recipes made easy."
        loadingSubheadingLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        loadingSubheadingLabel.textColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
        loadingSubheadingLabel.frame = CGRect(x: 0, y: loadingHeadingLabel.frame.maxY + 10, width: loadingSubheadingLabel.intrinsicContentSize.width, height: loadingSubheadingLabel.intrinsicContentSize.height)
        loadingSubheadingLabel.center = CGPoint(x: self.view.frame.width/2, y: progressBar.frame.minY - 20 - loadingSubheadingLabel.frame.height/2)
        loadingView.addSubview(loadingSubheadingLabel)
        
        loadingHeadingLabel.text = "RecipEase"
        loadingHeadingLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        loadingHeadingLabel.frame = CGRect(x: 0, y: 0, width: loadingHeadingLabel.intrinsicContentSize.width, height: loadingHeadingLabel.intrinsicContentSize.height)
        loadingHeadingLabel.center = CGPoint(x: self.view.frame.width/2, y: loadingSubheadingLabel.frame.minY - 10 - loadingHeadingLabel.frame.height/2)
        loadingView.addSubview(loadingHeadingLabel)
        
        progressDescription.text = "Loading GPT-3 Descriptions"
        progressDescription.font = UIFont.systemFont(ofSize: 13, weight: .light)
        progressDescription.textColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
        progressDescription.frame = CGRect(x: 0, y: progressBar.frame.maxY + 10, width: progressDescription.intrinsicContentSize.width, height: progressDescription.intrinsicContentSize.height)
        progressDescription.center.x = self.view.frame.width/2
        loadingView.addSubview(progressDescription)
        
        setProgressBarStatus()
    }
    
    ///Update the progress bar status with the current number of generated descriptions received from ChatGPT
    func setProgressBarStatus(){
        if(desserts.count == 0){
            return
        }
        progressBar.progress = Float(numDescriptionsLoaded)/Float(desserts.count)
        
        progressDescription.text = "Loading GPT-3 Descriptions (" + String(numDescriptionsLoaded) + "/" + String(desserts.count) + ")"
        progressDescription.frame.size = CGSize(width: progressDescription.intrinsicContentSize.width, height: progressDescription.intrinsicContentSize.height)
        progressDescription.center.x = self.view.frame.width/2
        
    }
    
    ///The main home screen layout containing a title, search bar, and table view.
    func setupMainView(){
        loadingView.removeFromSuperview()
        
        titleLabel.text = "Desserts"
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        titleLabel.frame = CGRect(x: view.safeAreaInsets.left + 20, y: view.safeAreaInsets.top + 30, width: titleLabel.intrinsicContentSize.width, height: titleLabel.intrinsicContentSize.height)
        self.view.addSubview(titleLabel)
        
        searchBar.frame = CGRect(x: view.safeAreaInsets.left + 6, y: titleLabel.frame.maxY + 10, width: self.view.frame.width - (view.safeAreaInsets.left + view.safeAreaInsets.right + 2 * 6), height: 30)
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        self.view.addSubview(searchBar)
        
        tableView.frame = CGRect(x: view.safeAreaInsets.left, y: searchBar.frame.maxY + 10, width: self.view.frame.width - (view.safeAreaInsets.left + view.safeAreaInsets.right), height: self.view.frame.height - view.safeAreaInsets.bottom - (titleLabel.frame.maxY + 20))
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }
    
    ///Calls the API to get the list of desserts, sorts it alphabetically, and removes any null values.
    func fetchDesserts(){
        APIManager.shared.getDessertList() {(desserts) in
            self.desserts = desserts.sorted(by: {$0.name < $1.name}).filter({$0.id != "" && $0.name != ""})
            self.displayedDesserts = self.desserts
            //once all the desserts have been loaded, call the ChatGPT API to generate descriptions.
            self.generateDescriptions()
        }
    }
    
    ///Calls the API to send a request to ChatGPT to generate a description for each dessert. As the descriptions are populated, the loading screen progress bar is updated, and the home screen is loaded when all the descriptions have been generated.
    func generateDescriptions(){
        for dessert in desserts {
            dessert.getGPTDescription { fetchedDescription in
                //return once all descriptions have been generated
                self.numDescriptionsLoaded = self.desserts.filter({$0.description != nil}).count
                self.setProgressBarStatus()
                if(self.numDescriptionsLoaded == self.desserts.count){
                    self.areDescriptionsLoaded = true
                    self.setupView()
                }
            }
        }
    }
}

///Table view delegate functions
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDesserts.count
    }
    
    ///Creating the layout of a UITableViewCell. Contains a main label (the name), the thumbnail image, and secondary text (the description). The names and descriptions are preloaded before loading the tableview into the view. The images are lazily loaded as the user scrolls, and cached in the NSCache in the ImageCache singleton.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") ?? UITableViewCell()
        
        let selectedDessert = displayedDesserts[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = selectedDessert.name
        content.textProperties.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        content.secondaryText = selectedDessert.description ?? selectedDessert.details?.getIngredientsDisplayString()
        content.secondaryTextProperties.color = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1)
        content.secondaryTextProperties.numberOfLines = 3
        
        content.image = selectedDessert.image ?? UIImage(named: "PlaceholderImage")
        content.imageProperties.maximumSize = CGSize(width: 80, height: 80)
        content.imageProperties.cornerRadius = 6
        
        //Fetch the image from the cache. The cache delivers the image asynchrously - either immediately if it is already cached, or when it receives the data from the api response.
        if let url = URL(string: desserts[indexPath.row].thumbnailURL){
            ImageCache.shared.getImage(url: url){image in
                //set the image and reload the table view
                if(image != selectedDessert.image){
                    selectedDessert.image = image
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.contentConfiguration = content
        
        return cell
    }
    
    ///Open the dessert details view controller when some dessert is tapped.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dessertViewController = DetailViewController()
        dessertViewController.dessert = displayedDesserts[indexPath.row]
        dessertViewController.modalPresentationStyle = .pageSheet
        self.present(dessertViewController, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

///Seach bar delegate functions - set the displayedDesserts array to a filtered subset from the whole list of dessert based on the user's search string.
extension HomeViewController: UISearchBarDelegate {
    ///When the user enters text in the search bar, the dessert list is filtered to those that match the search string. The output is sorted alphabetically.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.displayedDesserts = desserts.filter({$0.name.lowercased().contains(searchText.lowercased())}).sorted(by: {$0.name < $1.name})
        tableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        displayedDesserts = self.desserts
        tableView.reloadData()
    }
    

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

