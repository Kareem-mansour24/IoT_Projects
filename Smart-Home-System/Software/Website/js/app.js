import {
  getAuth,
  createUserWithEmailAndPassword,
} from "https://www.gstatic.com/firebasejs/10.13.0/firebase-auth.js";
import {
  getDatabase,
  ref,
  set,
} from "https://www.gstatic.com/firebasejs/10.13.0/firebase-database.js";

// Use the Firebase auth and database objects from the global window
const auth = window.auth;
const createUser = window.createUserWithEmailAndPassword;
const database = window.database;

function showAlert(message, type, callback) {
  const alertBox = document.getElementById("customAlert");
  const alertMessage = document.getElementById("alertMessage");
  alertMessage.textContent = message;
  alertBox.classList.remove("hidden");

  // Store the callback function to execute on alert dismissal
  window.alertCallback = callback;
}

function handleAlert() {
  const alertBox = document.getElementById("customAlert");
  alertBox.classList.add("hidden");
  if (window.alertCallback) {
    window.alertCallback(); // Execute the stored callback function
    window.alertCallback = null; // Clear the callback function
  }
}

document
  .getElementById("createAccountForm")
  .addEventListener("submit", function (event) {
    event.preventDefault(); // Prevent the default form submission behavior

    const name = document.getElementById("name").value;
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;

    createUser(auth, email, password)
      .then((userCredential) => {
        // Account created successfully
        const user = userCredential.user;
        const userId = user.uid;

        // Save additional user data to Firebase Realtime Database
        set(ref(database, "users/" + userId), {
          name: name,
          email: email,
        })
          .then(() => {
            showAlert(
              "Account created and user data saved successfully!",
              "success",
              () => {
                console.log("User data saved: ", { name, email });
                window.location.href = "register.html";
              }
            );
          })
          .catch((error) => {
            // Handle Database Errors
            console.error("Database Error:", "error", () => {
              showAlert("Error saving user data: " + error.message);
              window.location.reload(); // Reload the page
            });
          });
      })
      .catch((error) => {
        // Handle Authentication Errors
        const errorCode = error.code;
        const errorMessage = error.message;
        showAlert(
          `This email address is already associated with another account. Please use a different email or try to log in.`,
          "error",
          () => {
            console.error(
              "Error Code:",
              errorCode,
              "Error Message:",
              errorMessage
            );
            window.location.reload(); // Reload the page
          }
        );
      });
  });


  document.querySelector('#customAlert button').addEventListener('click', handleAlert);
