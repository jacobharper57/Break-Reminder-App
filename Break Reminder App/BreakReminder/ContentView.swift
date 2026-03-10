import SwiftUI
import UserNotifications

struct ContentView: View {
   
    @State private var breakFrequency = 60
    @State private var breakLength = 10
   
    @State private var scheduleRunning = false
    @State private var onBreak = false
   
    @State private var workTimeRemaining = 0
    @State private var breakTimeRemaining = 0
   
    @State private var timer: Timer?
   
    var body: some View {
       
        VStack(spacing: 25) {
           
            Text("Break Reminder")
                .font(.largeTitle)
                .fontWeight(.bold)
           
            Stepper(
                "Break every \(breakFrequency) minutes",
                value: $breakFrequency,
                in: 1...180
            )
           
            Stepper(
                "Break length \(breakLength) minutes",
                value: $breakLength,
                in: 1...30
            )
           
            if scheduleRunning && !onBreak {
               
                Text("Next Break In")
                    .font(.headline)
               
                Text(formatTime(workTimeRemaining))
                    .font(.system(size: 48))
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
           
            if onBreak {
               
                Text("Break Time Remaining")
                    .font(.headline)
               
                Text(formatTime(breakTimeRemaining))
                    .font(.system(size: 48))
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
           
            Button("Start Schedule") {
                startSchedule()
            }
            .buttonStyle(.borderedProminent)
           
            Button("Stop Schedule") {
                stopSchedule()
            }
            .buttonStyle(.bordered)
           
        }
        .padding()
        .onAppear {
            requestNotificationPermission()
        }
    }
   
    func startSchedule() {
       
        scheduleRunning = true
        onBreak = false
       
        workTimeRemaining = breakFrequency * 60
       
        timer?.invalidate()
       
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
           
            if !onBreak {
               
                if workTimeRemaining > 0 {
                    workTimeRemaining -= 1
                } else {
                    startBreak()
                }
            } else {
               
                if breakTimeRemaining > 0 {
                    breakTimeRemaining -= 1
                } else {
                    endBreak()
                }
            }
        }
    }
   
    func startBreak() {
       
        onBreak = true
        breakTimeRemaining = breakLength * 60
       
        sendNotification(
            title: "Break Time",
            message: "It's break time!"
        )
    }
   
    func endBreak() {
       
        onBreak = false
        workTimeRemaining = breakFrequency * 60
       
        sendNotification(
            title: "Break Finished",
            message: "Your break is over - time to get back to work"
        )
    }
   
    func stopSchedule() {
       
        scheduleRunning = false
        onBreak = false
        timer?.invalidate()
    }
   
    func formatTime(_ seconds: Int) -> String {
       
        let minutes = seconds / 60
        let seconds = seconds % 60
       
        return String(format: "%02d:%02d", minutes, seconds)
    }
   
    func requestNotificationPermission() {
       
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print("Notifications allowed")
            }
        }
    }
   
    func sendNotification(title: String, message: String) {
       
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
       
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
       
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
       
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    ContentView()
}
