//
//  MasterViewController.swift
//  CobaltTest
//
//  Created by Antonio Strijdom on 11/04/2018.
//  Copyright © 2018 Antonio Strijdom. All rights reserved.
//

import UIKit

/// View controller for displaying a list of Marvel characters
class MasterViewController: UITableViewController {
    
    // MARK: - Private

    var detailViewController: DetailViewController? = nil
    var characters: [MarvelCharacter]? = nil
    
    /// Display an error
    /// - Parameters:
    ///   - error: the error to display
    func displayErrorAlert(error: Error) {
        var errorText = "Unknown error"
        if let restError = error as? WebServiceMethodError {
            switch restError {
            case .InvalidURLError:
                errorText = "An invalid request was made"
            case .CommsError:
                errorText = "Could not contact SHIELD HQ. Please check your internet connection"
            case .HTTPError:
                errorText = "Could not process request"
            case .NoDataError:
                errorText = "No data returned"
            case .ParseError:
                errorText = "Could not process results"
            }
        }
        let alert = UIAlertController(title: "Something went wrong",
                                      message: errorText,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /// Displays the character in the cell
    /// - Parameters:
    ///   - character: the character to display
    ///   - cell: the cell to display them in
    func displayCharacter(_ character: MarvelCharacter, inCell cell: UITableViewCell) {
        cell.textLabel!.text = character.name
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            
            // load characters
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            CharactersWebMethod().getCharacters(withLimit: 50) { (result, error) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    self.displayErrorAlert(error: error)
                } else {
                    self.characters = MarvelCharacter.CharactersFromWebMethodResult(result: result)
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let characters = self.characters else {
            return
        }
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let character = characters[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = character
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - UITableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = nil
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let characters = self.characters else {
            return
        }
        guard indexPath.row < characters.count else {
            return
        }
        
        displayCharacter(characters[indexPath.row], inCell: cell)
    }


}

