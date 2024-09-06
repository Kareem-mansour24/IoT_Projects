// sign-in.js

import { getAuth, signInWithEmailAndPassword } from 'https://www.gstatic.com/firebasejs/10.13.0/firebase-auth.js';

// Get the Firebase auth object from the global window
const auth = window.auth;
const signIn = window.signInWithEmailAndPassword;

document.getElementById('signinForm').addEventListener('submit', function(event) {
    event.preventDefault(); // Prevent the default form submission behavior

    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    signIn(auth, email, password)
        .then((userCredential) => {
            // Sign-in successful
            const user = userCredential.user;
            localStorage.setItem('userId', user.uid); // Store the user ID in local storage
            showAlert("Sign-in successful! Redirecting to the dashboard...", "success", () => {
                window.location.href = "dashboard2.html"; // Redirect to the dashboard or another page
            });
        })
        .catch((error) => {
            // Handle Errors
            const errorMessage = error.message;
            showAlert(`Incorrect email or password. Please try again.`, "error", () => {
                window.location.reload(); // Reload the page
            });
        });
});

function showAlert(message, type, callback) {
    const alertBox = document.getElementById('customAlert');
    const alertMessage = document.getElementById('alertMessage');
    alertMessage.textContent = message;
    alertBox.classList.remove('hidden');
    
    // Store the callback function to execute on alert dismissal
    window.alertCallback = callback;
}

function handleAlert() {
    const alertBox = document.getElementById('customAlert');
    alertBox.classList.add('hidden');
    if (window.alertCallback) {
        window.alertCallback(); // Execute the stored callback function
        window.alertCallback = null; // Clear the callback function
    }
}

// Bind the handleAlert function to the OK button
document.querySelector('#customAlert button').addEventListener('click', handleAlert);

function togglePassword() {
    const passwordInput = document.getElementById('password');
    const toggleIcon = document.querySelector('.toggle-password');

    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        toggleIcon.classList.remove('fa-eye');
        toggleIcon.classList.add('fa-eye-slash');
    } else {
        passwordInput.type = 'password';
        toggleIcon.classList.remove('fa-eye-slash');
        toggleIcon.classList.add('fa-eye');
    }
}
