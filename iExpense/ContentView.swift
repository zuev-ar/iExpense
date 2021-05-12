//
//  ContentView.swift
//  iExpense
//
//  Created by Arkasha Zuev on 31.03.2021.
//

import SwiftUI

struct UserData: Codable {
    var firstName: String
    var lastName: String
}

class User: ObservableObject {
    @Published var firstName = "Bilbo"
    @Published var lastName = "Baggins"
}

struct FirstView: View {
    @ObservedObject var user = User()
    @State private var userData = UserData(firstName: "Bilbo2", lastName: "Bilbo2")
    @State private var tapCount = UserDefaults.standard.integer(forKey: "TapCount")
    @State private var currentNumber = 1
    @State private var numbers = [Int]()
    @State private var showingSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("Your name is \(user.firstName) \(user.lastName)")
                TextField("First name: ", text: $user.firstName)
                TextField("Last name: ", text: $user.lastName)
                Button("Show Sheet") {
                    showingSheet.toggle()
                }
                .sheet(isPresented: $showingSheet, content: {
                    SecondView(name: user.firstName)
                })
            }
            .padding()
            .background(Color.green)
            .cornerRadius(5)
            
            NavigationView {
                VStack {
                    List {
                        ForEach(numbers, id: \.self) { number in
                            Text("\(number)")
                        }
                        .onDelete(perform: removeRows)
                    }
                    Button("Add number"){
                        numbers.append(currentNumber)
                        currentNumber += 1
                    }
                }
                .padding()
                .background(Color.green)
                .cornerRadius(5)
                .navigationBarItems(leading: EditButton())
            }
            
            Button("Tap count: \(tapCount)"){
                tapCount += 1
                UserDefaults.standard.setValue(tapCount, forKey: "TapCount")
            }
            
            Button("Save User") {
                let encoder = JSONEncoder()

                if let data = try? encoder.encode(userData) {
                    UserDefaults.standard.set(data, forKey: "UserData")
                }
            }
        }
        .padding()
    }
    
    func removeRows(at offsets: IndexSet) {
        numbers.remove(atOffsets: offsets)
    }
}

struct SecondView: View {
    var name: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Hello, \(name)")
            Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
    }
}

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: String
    var amount: Int
}

class Expenses: ObservableObject {
    @Published var items = [ExpenseItem]() {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                self.items = decoded
            }
        } else {
            self.items = []
        }
    }
}

struct ContentView: View {
    @State var shownAddExpense = false
    @ObservedObject var expenses = Expenses()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(expenses.items) { item in
                    HStack {
                        VStack {
                            Text(item.name)
                                .font(.title)
                            Text(item.type)
                        }
                        Spacer()
                        Text("$\(item.amount)")
                            .font(.title)
                            .foregroundColor(amountColor(amount: item.amount))
                    }
                }
                .onDelete(perform: removeItem)
            }
            .navigationBarTitle("iExpense")
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                shownAddExpense.toggle()
            }) {
                Image(systemName: "plus")
            })
        }
        .sheet(isPresented: $shownAddExpense, content: {
            AddView(expenses: expenses)
        })
    }
    
    func removeItem(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
    
    func amountColor(amount: Int) -> Color? {
        if amount > 10 && amount < 99 {
            return Color.green
        } else if amount > 100 && amount < 999 {
            return Color.yellow
        } else if amount > 1000 {
            return Color.red
        } else {
            return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
