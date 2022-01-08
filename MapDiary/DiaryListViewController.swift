//
//  DiaryListViewController.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/16.
//

import UIKit
import RxSwift

class DiaryListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    let viewModel = DiaryListViewModel()
    
    var items: [DiaryItem] = []
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = viewModel.diaryItems
        
        DiaryListManager.shared.diaryItemChangedSubject
            .subscribe(onNext: reloadData)
            .disposed(by: disposeBag)

    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailItemSegue" {
            let vc = segue.destination as! DetailItemViewController
            let senderCell = sender as! DiaryItemCell
            let indexPath = self.tableView.indexPath(for: senderCell)
            guard let index = indexPath else {return}
            let item = items[index.row]
            
            vc.diaryItem = item
        }
    }
    
    private func reloadData(reload: Bool) {
        if (!reload) { return }
        
        items = viewModel.diaryItems
        tableView.reloadData()
    }
}

extension DiaryListViewController: UITableViewDelegate  {
    
}

extension DiaryListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numOfDiaryItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryItemCell", for: indexPath) as? DiaryItemCell else { return UITableViewCell()}
        
        let item = items[indexPath.row]
        cell.photo.image = item.image
        cell.date.text = item.date.toString(dateFormat: "yyyy-MM-dd")
        cell.title.text = item.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteItem = items[indexPath.row]
            viewModel.delete(item: deleteItem)
            items = viewModel.diaryItems
            tableView.deleteRows(at: [indexPath], with: .fade)
       }
    }
}
