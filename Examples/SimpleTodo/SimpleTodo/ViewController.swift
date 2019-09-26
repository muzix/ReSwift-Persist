//
//  ViewController.swift
//  SimpleTodo
//
//  Created by muzix on 9/8/19.
//  Copyright © 2019 muzix. All rights reserved.
//

import UIKit
import ReSwift
import ReSwift_Persist
import Dwifft

struct TodoItem: Codable, Equatable {
    let title: String
    let description: String?
    let timestamp = Date()
}

struct AppState: PersistState {
    var todos: [TodoItem]
}

struct AddTodoAction: Action {
    let todo: TodoItem
}

struct RemoveTodoAction: Action {
    let index: Int
}

func todoReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState(todos: [])
    switch action {
    case let addAction as AddTodoAction:
        state.todos.append(addAction.todo)
    case let removeAction as RemoveTodoAction:
        guard removeAction.index >= 0 && removeAction.index < state.todos.count else { break }
        state.todos.remove(at: removeAction.index)
    default:
        break
    }
    return state
}

//let appStore = Store<AppState>(reducer: todoReducer, state: nil)
var persistConfig: PersistConfig = {
    var config = PersistConfig(persistDirectory: "data", version: "1")
    config.debug = true
    return config
}()
let appStore = PersistStore(config: persistConfig, reducer: todoReducer, state: nil)

class ViewController: UITableViewController, StoreSubscriber {

    var todos: [TodoItem] = [] {
        didSet {
            self.diffCalculator?.rows = todos
        }
    }

    var diffCalculator: SingleSectionTableViewDiffCalculator<TodoItem>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.diffCalculator = SingleSectionTableViewDiffCalculator(
            tableView: self.tableView,
            initialRows: self.todos,
            sectionIndex: 0
        )
        self.diffCalculator?.deletionAnimation = .top
        self.diffCalculator?.insertionAnimation = .top
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appStore.subscribe(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appStore.unsubscribe(self)
    }

    func newState(state: AppState) {
        self.todos = state.todos
    }

    @IBAction func btnAddTouched(_ sender: Any) {
        let todoForm = UIAlertController(title: "New item", message: nil, preferredStyle: .alert)
        todoForm.addTextField { textField in
            textField.placeholder = "Title"
        }
        todoForm.addTextField { textField in
            textField.placeholder = "Description"
        }
        let action = UIAlertAction(title: "Add", style: .default) { _ in
            let textFields = todoForm.textFields
            guard let title = textFields?[0].text, title.isEmpty == false else { return }
            let description = textFields?[1].text
            appStore.dispatch(AddTodoAction(todo: TodoItem(title: title,
                                                           description: description)))
        }
        todoForm.addAction(action)
        self.present(todoForm, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        guard indexPath.row < todos.count else { return cell }
        let todo = todos[indexPath.row]
        cell.textLabel?.text = todo.title
        cell.detailTextLabel?.text = todo.description
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            appStore.dispatch(RemoveTodoAction(index: indexPath.row))
        }
    }

}
