Digital Tasbeeh Mobile App (Flutter)
The Digital Tasbeeh Mobile App is a modern, smartphone-based version of the traditional Islamic prayer counter (tasbeeh or misbaha) used by Muslims to recite and keep count of dhikr (remembrances of Allah), durood, or other supplications.
This app enables users to count their dhikr anytime, anywhere using their mobile phone. It combines simplicity, focus, and aesthetics to enhance the spiritual experience without distractions.
Mobile Screens
1. Home Screen
2. Stats Screen
3. Manage Tasbeeh Screen
Home Screen
•	Features a large circular modern counter that increments its value whenever the screen is tapped.
•	Above the counter is a horizontal action bar with the following options:
•	   - Sound: Toggle on/off the counting sound
•	   - Vibrate: Toggle on/off vibration feedback
•	   - Undo
•	   - Reset
•	   - Rate App
(the counter and the action bar design is in counterdesign.json file check thatout)
•	Below the counter, the Tasbeeh name is displayed.
•	The counter includes a circular progress ring. Inside the ring, the current count of the Tasbeeh is shown.
•	If the Tasbeeh has a set count limit, the total count target is also displayed. After completing each set, the round number increases, which is also visible within the counter.
Navigation Bar
A floating, modern navigation bar with three buttons:
1. Home
2. + (Manage Tasbeeh) – to select the Tasbeeh to count
3. Stats
Manage Tasbeeh Screen
•	Includes a default Tasbeeh named Sallallahu Alayhi Wasallam with no count limit.
•	Preloaded with other Tasbeehs such as SubhanAllah, Allahu Akbar, Alhamdulillah, etc., with and without count limits.
•	Users can create, edit, and delete custom Tasbeehs with specific count limits or targets.
•	The default Tasbeeh automatically opens whenever the app is launched.
•	Users can select the Tasbeeh they wish to recite from this screen.
Stats Screen
•	Displays Total Counts, showing all real-time and accurate counts the user has accumulated.
•	Includes a bar graph with Week / Month / Year tabs to visualize daily, weekly, and monthly progress.
•	Features a pie chart showing the distribution of different Tasbeehs with percentages and total counts.
•	All stats are saved in real time and remain persistent — they are not erased or reset when switching Tasbeehs or closing the app.
Other Details
•	Built for Android using Flutter (Dart).
•	Designed with a consistent iOS-style (Cupertino) aesthetic and smooth, modern animations.
•	Supports both light and dark themes.
•	Includes reminder notifications to encourage regular dhikr.
•	Integrated with Firebase FCM (for push notifications) and Firebase Analytics (for performance and user behavior tracking).
