// firebase.js

import { initializeApp } from "https://www.gstatic.com/firebasejs/10.13.0/firebase-app.js";
import { getDatabase, ref, onValue } from "https://www.gstatic.com/firebasejs/10.13.0/firebase-database.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.13.0/firebase-auth.js";

// Your Firebase configuration object
const firebaseConfig = {
  apiKey: "AIzaSyD7y4xBWgc1eEfiTpTJ7RuUh-6TLAq6LaI",
  authDomain: "smart-home-2bd36.firebaseapp.com",
  databaseURL: "https://smart-home-2bd36-default-rtdb.firebaseio.com",
  projectId: "smart-home-2bd36",
  storageBucket: "smart-home-2bd36.appspot.com",
  messagingSenderId: "957427179773",
  appId: "1:957427179773:web:73eeaa37d6ccb43cdb79e94",
  measurementId: "G-8383S2QC3K",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const database = getDatabase(app);
const auth = getAuth(app);

function displayUserName() {
  const userId = localStorage.getItem('userId'); // Retrieve the user ID from local storage
  if (userId) {
    const userRef = ref(database, "users/" + userId + "/name");

    // Listen for changes in the user's name in the database
    onValue(userRef, (snapshot) => {
      if (snapshot.exists()) {
        const userName = snapshot.val();
        console.log("User name found: ", userName);

        // Update elements with the user's name
        const profileNameElement = document.querySelector(".profile-name");
        if (profileNameElement) {
          profileNameElement.textContent = `${userName}`;
        }

        const headerWelcomeElement = document.querySelector(".header-welcome");
        if (headerWelcomeElement) {
          headerWelcomeElement.textContent = `Welcome, ${userName}!`;
        }
  
      } else {
        console.warn("User name not found in the database.");
      }
    }, (error) => {
      console.error("Error reading user name from database:", error);
    });
  } else {
    console.warn("No user ID found in local storage.");
  }
}

// Call the function to display the user's name
displayUserName();
