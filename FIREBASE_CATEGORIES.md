# Adding book categories in Firebase

BookVerse does not use a separate `categories` collection. A category is the
`category` string field on each document in the top-level `books` collection.
The Library screen builds its category filter from the categories of the books
it has loaded. Use the same spelling and capitalization for books that should
appear under the same filter.

## Recommended: add a book in BookVerse

1. Sign in to BookVerse.
2. Open **Library** and choose **Add to library** > **Add a book or PDF link**.
3. Enter a title, author, and category (for example, `Science` or `History`).
   Add a description; the reading text, PDF URL, and page count are optional.
4. Choose **Save book**.

The app writes the book to Firestore at `books/{bookId}`, including the
category and the signed-in user's UID in `createdBy`. The Firestore rules allow
the signed-in user to create a book they own. Once the book has loaded, its
category appears as a filter in the Library.

## Add a book manually in Firebase Console

1. Open the Firebase project used by this app.
2. Go to **Firestore Database** > **Data**.
3. Open the `books` collection. If it does not exist, choose **Start
   collection** and enter `books`.
4. Add a document with an automatically generated document ID.
5. Add the following fields. Firestore field types matter:

   | Field | Type | Example |
   | --- | --- | --- |
   | `title` | string | `Introduction to Biology` |
   | `author` | string | `A. Student` |
   | `category` | string | `Science` |
   | `description` | string | `Basic biology concepts` |
   | `createdBy` | string | The UID of the signed-in Firebase Authentication user |
   | `createdAt` | timestamp | The current date and time |

   Optional fields supported by the app include `content` (string), `pdfUrl`
   (string), `page` (number), `total` (number), `size` (string), `date`
   (string), `color` (number), and `rating` (number). For an online PDF, set
   `pdfUrl` to a reachable HTTP(S) URL.

6. Save the document, then refresh or reopen the Library in BookVerse.

The included `firestore.rules` requires the `createdBy` value to match the
current user's UID and requires `title`, `author`, and `category` to be
strings when a book is created in the app. Only the account whose UID is in
`createdBy` can read, update, or delete that book through the app.
Firestore Console access is privileged, so manually adding a document there
does not exercise those client-side rules; use the intended owner's UID as
`createdBy` if the app should allow that user to access it.

## Change a category

Edit the book document's `category` field in Firestore, or add the same book
again with the corrected category from the app. The category filters are
derived from loaded books; there is no separate category record to create.

## Categorize a local PDF

When importing a PDF from the device, enter an optional title, author, and
category in the details dialog. The filename (without `.pdf`) is used when the
title is left blank, `Unknown author` is used when the author is blank, and
`Local PDFs` is used when the category is blank. A custom local-PDF category
appears in the same Library category filters as categories from Firestore.
