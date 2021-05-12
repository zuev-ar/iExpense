//
//  AddView.swift
//  iExpense
//
//  Created by Arkasha Zuev on 08.04.2021.
//

import SwiftUI

struct AddView: View {
    @State var name = ""
    @State var type = ""
    @State var amount = ""
    @State var showingAlert = false
    @ObservedObject var expenses: Expenses
    @Environment(\.presentationMode) var presentationMode
    
    static let types = ["Business", "Personal"]
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Amount", text: $amount)
                    .keyboardType(.numberPad)
                Picker("Type", selection: $type) {
                    ForEach(AddView.types, id: \.self) {
                        Text($0)
                    }
                }
            }
            .navigationBarTitle("Add new expense")
            .navigationBarItems(trailing: Button("Save", action: {
                if let actualAmount = Int(amount) {
                    let item = ExpenseItem(name: name, type: type, amount: actualAmount)
                    expenses.items.append(item)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showingAlert = true
                    amount = ""
                }
            })
            .alert(isPresented: $showingAlert, content: {
                Alert(title: Text("Error"), message: Text("You entered the wrong number"), dismissButton: .default(Text("Ok")))
            })
            )
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expenses: Expenses())
    }
}
