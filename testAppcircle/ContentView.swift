//
//  ContentView.swift
//  testAppcircle
//
//  Created by Burak Öztopuz on 28.03.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var notificationManager = NotificationManager()
        var body: some View{
            VStack{
                Button("Request Notification"){
                    Task{
                        await notificationManager.request()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(notificationManager.hasPermission)
                .task {
                    await notificationManager.getAuthStatus()
                }
                
                Button("Send Push Notification"){
                         PushNotificationManager.sendPushNotification()
                }
                .buttonStyle(.bordered)
                .disabled(notificationManager.hasPermission)
            }
        }
}

#Preview {
    ContentView()
}


@MainActor final
class UtilsViewModel: ObservableObject {
    @Published var hasPermission = false
    
    func getAuthStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            self.hasPermission = true
        default:
            self.hasPermission = false
        }
    }
    
    func requestNotificationPermission() async {
        do {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            self.hasPermission = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)

            UIApplication.shared.registerForRemoteNotifications()
        } catch {
            print(error.localizedDescription)
        }
    }
}
