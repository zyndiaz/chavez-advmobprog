# Laboratory 5 Discussion

## DummyJSON and Firebase Workflow

The sign-in screen lets the user choose either DummyJSON or Firebase. When DummyJSON is selected, the app sends the username and password to DummyJSON's `POST /auth/login` endpoint. `UserService` parses the returned account details and access and refresh tokens, then saves the session locally with `SharedPreferences`. DummyJSON is used for sign-in in this laboratory; it does not provide the app's Firebase signup flow.

When Firebase is selected, the user can sign in with an email address and password or open the signup screen. Signup validates the first name, last name, age, contact number, username, email, and password, then `UserService` creates the account with Firebase Authentication. It stores the additional profile fields in a Firestore document at `users/{uid}`. After either type of sign-in or a successful signup, the app opens the home screen. The splash screen checks the saved session when the app starts, and logout clears the local session and signs out of Firebase when applicable.

## Main Idea of UserService

`UserService` centralizes authentication and user-session operations so screens do not need to call Firebase, Firestore, DummyJSON, or `SharedPreferences` directly. The `LoginType` records which backend is active, allowing profile reads and account actions to use the matching implementation. The service handles sign-in, account creation, profile updates, password changes, account deletion, logout, and access-token retrieval or refresh. Screens are then responsible for collecting input, displaying feedback, and navigating between routes.

## Benefits of Firebase in This Application

Firebase Authentication provides managed email-and-password accounts without the app storing users' passwords. The Firebase SDK maintains the signed-in session and can refresh ID tokens when needed. Firestore gives Firebase users a persistent profile linked to their unique UID, while the deployed security rules restrict access to each user's own document. Together, Authentication and Firestore make the app's signup, profile, and account-management flows real backend operations, complementing DummyJSON's API-based login demonstration.

