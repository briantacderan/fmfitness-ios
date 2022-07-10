//
//  ApptDelegate.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/18/22.
//

import SwiftUI

struct ApptDropDelegate: DropDelegate {
    @Binding var focusId: Int?
    //@ObservedObject var firestore = FirestoreManager.shared
    
    func performDrop(info: DropInfo) -> Bool {
        guard
            info.hasItemsConforming(to: [TodoItem.typeIdentifier])
        else { return false }

        let itemProviders = info.itemProviders(for: [TodoItem.typeIdentifier])
        guard
            let itemProvider = itemProviders.first
        else { return false }

        itemProvider.loadObject(ofClass: TodoItem.self) { todoItem, _ in
            let todoItem = todoItem as? TodoItem

            DispatchQueue.main.async {
                self.focusId = todoItem?.id
            }
        }
        return true
    }
}


/*
struct dropHere<DropInfo: View, Content: View>: View {
    
    let dropInfo: DropInfo
    let mainContent: Content
    @Binding var focusId: Int?
    
    init(dropInfo: DropInfo, focusId: Binding<Int>, @ViewBuilder sidebar: ()->SidebarContent, @ViewBuilder content: ()->Content) {
        self.sidebarWidth = sidebarWidth
        self._showSidebar = showSidebar
        sidebarContent = sidebar()
        mainContent = content()
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            sidebarContent
                .frame(width: sidebarWidth, alignment: .center)
                .offset(x: showSidebar ? 0 : -1 * sidebarWidth, y: 0)
             
            mainContent
                .overlay(
                    Group {
                        if showSidebar {
                            Color.white
                                .opacity(showSidebar ? 0.01 : 0)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        self.showSidebar = false
                                    }
                                }
                        } else {
                            Color.clear
                            .opacity(showSidebar ? 0 : 0)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    self.showSidebar = false
                                }
                            }
                        }
                    }
                )
                .offset(x: showSidebar ? sidebarWidth : 0, y: 0)
        }
    }
}
 

struct PullToRefresh: View {
    
    var coordinateSpaceName: String
    var onRefresh: ()->Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 50) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 40) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                        .font(.system(size: 30))
                } else {
                    VStack {
                        LogoView(logoWidth: 100, logoHeight: 20, vertPadding: 0)
                        
                        Image(systemName: "chevron.compact.down")
                            .resizable()
                            .frame(width: 40, height: 10)
                    }
                    .tint(Color("B1-red"))
                    .foregroundColor(Color("B1-red"))
                }
                Spacer()
            }
        }
        .padding(.top, -30)
    }
}
*/
