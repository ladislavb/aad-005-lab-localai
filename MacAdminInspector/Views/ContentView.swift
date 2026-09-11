import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    OverviewView()
                } label: {
                    Label("Overview", systemImage: "rectangle.3.group")
                }

                NavigationLink {
                    NetworkView()
                } label: {
                    Label("Network", systemImage: "network")
                }

            }
            .navigationTitle("Mac Admin Inspector")
        } detail: {
            OverviewView()
        }
        .frame(minWidth: 720, minHeight: 500)
    }
}
