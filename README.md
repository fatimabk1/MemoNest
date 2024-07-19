# MemoNest
MemoNest is a voice memo app designed to enhance organization through nested structure capabilities. It allows users to categorize their memos into hierarchical folders, providing a structured approach to managing and accessing recordings. Users can easily reorganize files and folders within the app, facilitating intuitive management of their memo collection.

**Key Technologies:** Swift, SwiftUI, Realm, XCTest, AVAudioPlayer, and AVAudioRecorder.
## Key Design Decisions
**Single Page UI for Recording and Playback**

I chose to design a streamlined, single page interface for recording and playback. The main view model owns the ```RecordingService``` and ```PlaybackService```. The view model subscribes to state updates via Combine, driving the UI to reflect recording and playback states in real-time. This approach improves modularity and responsiveness, making the UI more intuitive and reducing the complexity of handling state changes.

**Single Page UI for Navigation**

Navigating through many nested folders could potentially lead to a stack overflow by stacking multiple screens. Updating the displayed folder within a single page UI prevents the screen stack from growing too large, thus avoiding stack overflow issues. Using a single page UI for navigation enhances performance and reliability, especially with deep folder structures, while keeping the navigation flow straightforward.

**Selection of Realm for the Database**

Choosing the right database technology for local storage was crucial for app performance and future scalability. Realm was selected over other database technologies because it offers high performance for local data storage and provides opportunities for cloud and sync support in future releases. This aligns with potential future needs for data synchronization and scalability. This decision improves the app’s current performance and provides a scalable path for future features, such as cloud integration and data synchronization.

**Dependency Injection with DataManager Protocol**

I wanted to be able to easily swap between the mock database for testing and the Realm database when used in production. Implementing dependency injection by creating Realm and mock databases conforming to a ```DataManager``` protocol (Strategy Pattern) allows easy swapping of database implementations. This enhances testability and modularity, making it easier to switch between real and mock databases during development and testing phases.

**Data Mapper Pattern for Object-Database Separation**

I wanted to clearly separate the domain logic from the database representation. Using the Data Mapper Pattern to create a layer of abstraction between code and database isolates mapping logic, allowing flexibility to swap the database layer without changing object representation throughout the code. This improves maintainability and flexibility, making future database migrations or changes less disruptive.

**BFS Folder Deletion with Combine**

Deleting folders efficiently without data integrity issues is crucial to the apps performance and data accuracy. Implementing BFS folder deletion with Combine, where items are structured to save the ID of their parent folder, allows safe deletion without damaging data integrity. Items are displayed by searching for all items with a parentID of the current folder. This ensures data integrity and improves the performance of folder deletion and item display operations.

**Unified Item Protocol for Files and Folders**

The view needed to display files and folders interchangeably. Having both files and folders conform to the Item protocol allows the view to handle them uniformly without needing to know their exact types (Composite Pattern). This simplifies the UI code and enhances reusability and flexibility in handling different item types.

## Organizational and Stylistic Decisions
**FormatterService for Date/Time Formatting**

Redundant date and time formatting code needed consolidation. Creating a FormatterService centralizes all date and time formatting logic, making it reusable across the app. This reduces code redundancy and improves maintainability by having a single source for formatting logic.

**Custom Input Pop-Up UI Element**

Consistent theming for renaming and adding folders was required. Developing a custom input pop-up UI element and data structure ensures that these actions match the app's theming and extract common code. This improves UI consistency and reduces repetitive code, making it easier to maintain and update the input elements.

**Private Computed Properties for UI Components**

The code needed to be modular, reusable, and readable. I used private computed properties for UI components in SwiftUI to ensure modularity, reusability, and readability. This also cleans up the code organization and makes the UI components easier to maintain and update.

**Custom Font Modifier**

Applying fonts consistently throughout the app was challenging and required specifying the font name throughout the code. Implementing a custom font modifier that takes font weight and style improves readability, consistency, and maintainability. Changes to the font now occur in one location instead of being scattered throughout the code. This creates consistency of the app’s typography and makes it easier to manage and update fonts globally.
