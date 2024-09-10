// Update with your actual username and password for the MQTT broker
const options = {
    username: 'faresmohamed260', // Replace with your MQTT username
    password: '#Rmc136a1drd47r', // Replace with your MQTT password
    clean: true, // Use a clean session to avoid issues with retained topics
    reconnectPeriod: 1000, // Reconnect after 1 second if disconnected
    connectTimeout: 30 * 1000, // Timeout after 30 seconds
};

// Connect to the MQTT broker using secure WebSocket (wss://)
const client = mqtt.connect('wss://7723500f166547509bc34df058860232.s1.eu.hivemq.cloud:8884/mqtt', options); // Ensure the broker URL and port are correct

// MQTT Topic for password change
const changePasswordTopic = 'change_password';

// Initialize the Change Password functionality
function initializeChangePassword() {
    const form = document.getElementById('change-password-form');
    const currentPasswordInput = document.getElementById('current-password');
    const newPasswordInput = document.getElementById('new-password');
    const confirmPasswordInput = document.getElementById('confirm-password');
    const notification = document.getElementById('notification');
    const backButton = document.getElementById('back-button');

    let currentPassword = '1234'; // Simulated current password, replace with the real one from your system

    // Handle MQTT connection event
    client.on('connect', () => {
        console.log('Connected to MQTT broker');

        // Subscribe to the change password topic
        client.subscribe(changePasswordTopic, (err) => {
            if (err) {
                console.error('Failed to subscribe to change_password topic:', err);
            } else {
                console.log('Subscribed to change_password topic');
            }
        });
    });

    // Handle incoming MQTT messages
    client.on('message', (topic, message) => {
        if (topic === changePasswordTopic) {
            const newPassword = message.toString();
            currentPassword = newPassword; // Update the current password
            showSuccessNotification('Password has been changed successfully.');
        }
    });

    // Handle form submission for changing password
    form.addEventListener('submit', (e) => {
        e.preventDefault();

        if (currentPasswordInput.value !== currentPassword) {
            showErrorDialog('Current password is incorrect.');
            return;
        }

        if (newPasswordInput.value !== confirmPasswordInput.value) {
            showErrorDialog('New passwords do not match.');
            return;
        }

        // Publish the new password to the MQTT topic
        client.publish(changePasswordTopic, newPasswordInput.value, (error) => {
            if (error) {
                console.error('Failed to publish new password:', error);
                showErrorDialog('Failed to change password.');
            } else {
                console.log('Published new password successfully');
            }
        });
    });

    // Show success notification
    function showSuccessNotification(message) {
        notification.textContent = message;
        notification.style.color = 'green';
    }

    // Show error dialog
    function showErrorDialog(message) {
        alert(message);
    }

    // Handle back button click to navigate back to the previous page
    backButton.addEventListener('click', () => {
        window.history.back();
    });
}

// Initialize the script once the DOM is fully loaded
document.addEventListener('DOMContentLoaded', initializeChangePassword);
