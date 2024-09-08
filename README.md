# Social Media App

The Social Media App is a Flutter application with Firebase integration that allows users to manage profiles, create posts, send friend requests, and more. The app features a retro-inspired UI with a focus on user-friendly interactions and real-time updates through Firestore.

## User Authentication
- **Sign In / Sign Up**: Using **Firebase Authentication**, users can create a new account or sign in to an existing one with their email and password.

<p align="center">
<img src="https://github.com/user-attachments/assets/839458b4-9d96-4a49-ac45-10541a1d128a" width="250">
<img src="https://github.com/user-attachments/assets/88750879-1f5f-43a7-9e98-4c2fccedd13f" width="250">
<img src="https://github.com/user-attachments/assets/fff6357b-b635-40c2-ba60-e3d75005c11a" width="250">
</p>

- **Password Reset**: Users can reset their password through a dedicated option in the profile section, handled by **Firebase Authentication**.

<p align="center"> <img src="https://github.com/user-attachments/assets/a76b36a2-004f-4032-9fde-cbdd38b76a98" width="250"> </p>

- **Sign Out**: Users can securely log out of their account.

<p align="center">
<img src="https://github.com/user-attachments/assets/33b9b309-039d-4407-8be0-69f2718c5059" width="250">
</p>

- **Account Deletion**: Users can delete their account, which also removes all associated data from **Firestore**.

<p align="center">
<img src="https://github.com/user-attachments/assets/4f017cd3-da54-4182-8bc5-893046966d6d" width="250">
</p>

## Profile Management
- **User Profile**: Each user has a profile displaying their username, email, and profile picture.
  
<p align="center">
<img src="https://github.com/user-attachments/assets/86bd6bf5-12be-454f-a69c-393a31723092" width="250">
</p>
  
- **Edit Profile**: Users can update their username directly from the profile screen.

<p align="center">
<img src="https://github.com/user-attachments/assets/c665d816-7c4b-4794-849a-0680fc7b72f9" width="250">
</p>

- **Retro-Style UI**: The app features a retro-themed UI with custom fonts, colors, buttons, and styling designed to evoke a nostalgic feel.

## User Feed
- **All Posts**: Displays a feed of posts from both the user and their friends, sorted by the time elapsed since each post was made.

<p align="center">
<img src="https://github.com/user-attachments/assets/73597c1e-f776-40a4-9df1-550c2a6d5499" width="250">
</p>

- **My Posts**: A dedicated section that shows only the user’s own posts for easier content management.

<p align="center">
<img src="https://github.com/user-attachments/assets/a8d08fd4-c394-4878-8546-4d851fd1f96f" width="250">
</p>

- **Create Post**: Allows users to share their thoughts by composing and submitting text-based posts.

<p align="center">
<img src="https://github.com/user-attachments/assets/2821903e-bd1b-49e2-8276-26a1132dddc8" width="250">
</p>

- **Edit/Delete Functionality**: Users can edit or delete their posts directly from both the "All Posts" and "My Posts" sections, providing convenient post management, with all actions synced in real-time via **Firestore**.

<p align="center">
<img src="https://github.com/user-attachments/assets/5322a369-4ed6-4c45-b79e-cfe1ae83b42a" width="250">
<img src="https://github.com/user-attachments/assets/4dddee02-232e-4695-93b3-3f687760bf04" width="250">
</p>

- **Firestore Integration**: All posts are stored under the user’s **Firestore** document for personalized data retrieval and real-time updates.

## Friend Management
- **Send/Cancel Friend Requests**: Users can search for other users and send or cancel friend requests from the search screen, with data managed through **Firestore**.

<p align="center">
<img src="https://github.com/user-attachments/assets/19841949-1d25-4317-84c8-502c776ce553" width="250">
<img src="https://github.com/user-attachments/assets/fbb58196-3ac5-4b08-90ce-d237219a0073" width="250">
</p>

- **Accept/Reject Friend Requests**: Incoming friend requests can be accepted or rejected directly from the friends screen or through the search screen.

<p align="center">
<img src="https://github.com/user-attachments/assets/35799a31-ae3c-4758-b1aa-3fc2161f681b" width="250">
</p>

- **Friendship Management**: Once a friendship is confirmed, users can remove friends if desired. This can be done by searching for the user on the search screen or through the friends screen.
  
<p align="center">
<img src="https://github.com/user-attachments/assets/a23c34c5-a9b3-4908-b596-6c1e09ab35b0" width="250">
<img src="https://github.com/user-attachments/assets/15d4c246-7dc6-404b-be0f-d363691183f2" width="250">
</p>

## Firestore Integration
- **Real-Time Updates**: The app uses **Firestore** for real-time updates across the user profile, friends, posts, and search functionality.
- **Efficient Data Structure**: Posts, friend requests, and user data are stored in structured **Firestore** collections for fast and efficient access to feed updates, friend management, and search results.
- **Error Handling and Validation**: Firestore handles errors during friend request processing and profile updates, while input fields in sign-in, sign-up, and post creation forms are validated with clear error messages for incorrect inputs.
