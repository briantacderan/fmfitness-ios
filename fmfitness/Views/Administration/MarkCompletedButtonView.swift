//
//  MarkCompletedButtonView.swift
//  fm-fitness
//
//  Created by Brian Tacderan on 5/20/22.
//
/*
import SwiftUI

struct MarkCompletedButtonView: View {
    @Binding var appts: [TodoItem]
    @Binding var selected: [Int]
  
    var tasks: FirestoreManager

    var body: some View {
        if !selected.isEmpty {
            Button(action: {
                for index in selected {
                    let id = appts[index].id
                    tasks.markCompleteStatus(id: id, complete: true)
                }
                selected.removeAll()
            }, label: {
                Text("Mark Selected Complete")
            })
        }
    }
}

struct MarkCompletedButtonView_Previews: PreviewProvider {
    static var previews: some View {
        MarkCompletedButtonView()
    }
}
*/
