# Lab Activity 3: Discussion

## Laboratory Discussion

The `Cart` and `CartProduct` models map the JSON returned by DummyJSON into typed Dart objects. `CartService` handles network requests, while `CartScreen` loads the user's cart, displays its products, and combines API data with local `CartProvider` state so cart changes appear immediately. Adding a product sends a request to `/carts/add`; the product catalog is loaded separately by `ProductService`.

`ProductDetailScreen` can display either a catalog `Product` or a `CartProduct`. The cart screen opens this screen when a cart item is selected. Product cards currently show their details in a modal within `ProductScreen`, so routing both flows through `ProductDetailScreen` would make the detail experience fully shared. This design separates API/data mapping, service logic, state management, and UI responsibilities, making each part easier to maintain.

To retrieve one cart by its cart ID, use DummyJSON's `GET /carts/{cartId}` endpoint (for example, `/carts/1`) and convert the response with `Cart.fromJson`. This is different from the current `getCartsByUserId` request to `/carts/user/{userId}`, which finds carts belonging to a user. A `getCartById` service method can use the first endpoint when a specific cart is needed.

