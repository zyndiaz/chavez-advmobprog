# Lab Activity 4: Discussion

When a DummyJSON account signs in, `UserService` sends its credentials to `POST /auth/login` and converts the response into the `User` model. The service saves the user ID, profile fields, and tokens with `SharedPreferences`. `ProfileScreen` calls `getUser()` to rebuild the model from saved data, then renders the user's name, image, email, gender, and ID. The local demo account Zyn Diaz (`zyn` / `zynpass`) follows the same save-and-render flow, but is stored locally rather than created on DummyJSON.

The updated design follows a model-service-screen pattern: `User` defines the profile data, `UserService` owns API and persistence work, and `SignInScreen`, `SplashScreen`, and `ProfileScreen` handle the UI and session flow. The splash checks the saved token to decide whether to open the shop or sign-in; signing out clears the saved session.

`CartScreen` retrieves the saved user with `UserService.getUser()`, takes `user.id`, and requests that user's cart from `GET /carts/user/{userId}`. Cart items from the response are combined with local `CartProvider` items so newly added products appear immediately. Product and detail screens also submit the saved user ID when adding products, avoiding a hard-coded account ID.

