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

// Initialize the door controls and MQTT connection
function initializeDoorControl() {
    const passwordDisplay = document.getElementById('password-display');
    const doorStatusText = document.getElementById('door-status-text');
    const doorIcon = document.getElementById('door-icon');
    const changePasswordButton = document.getElementById('change-password-button');
    const backButton = document.getElementById('back-button');
    const keypadButtons = document.querySelectorAll('.keypad-button');
    const passwordFeedback = document.getElementById('password-feedback');

    let enteredPassword = '';
    const correctPassword = '1234'; // Example correct password
    let doorStatus = 'Locked'; // Initial door status
    let doorOpenedByWeb = false; // Tracks if the door was opened by the web page

    // Ensure all elements are found before proceeding
    if (!passwordDisplay || !doorStatusText || !doorIcon || !changePasswordButton || !backButton || !passwordFeedback) {
        console.error('One or more elements are missing from the DOM.');
        return;
    }

    // MQTT Connection Event
    client.on('connect', () => {
        console.log('Connected to MQTT broker');
        // Subscribe to the front_door topic to listen for door status changes
        client.subscribe('front_door', (err) => {
            if (err) {
                console.error('Failed to subscribe to front_door:', err);
            } else {
                console.log('Subscribed to front_door topic');
            }
        });
    });

    // Handle incoming messages from subscribed topics
    client.on('message', (topic, message) => {
        const messageStr = message.toString().trim().toUpperCase();

        if (topic === 'front_door') {
            // Update door status based on the message received from the topic
            doorStatus = messageStr === 'UNLOCKED' ? 'Unlocked' : 'Locked';
            updateDoorStatus(doorStatus);
        }
    });

    // Update door status display
    function updateDoorStatus(status) {
        doorStatusText.textContent = status;
        doorIcon.className = status === 'Unlocked' ? 'fas fa-lock-open' : 'fas fa-lock';
        doorStatusText.style.color = status === 'Unlocked' ? 'green' : 'red';
    }

    // Handle number press on the keypad
    keypadButtons.forEach(button => {
        button.addEventListener('click', () => {
            if (button.id === 'clear-button') {
                enteredPassword = '';
                passwordFeedback.textContent = ''; // Clear feedback
            } else if (button.id === 'submit-button') {
                if (enteredPassword === correctPassword) {
                    // Publish UNLOCKED to the front_door topic when the door is unlocked
                    client.publish('unlock_button', 'LOW', { qos: 0, retain: false }, (error) => {
                        if (error) {
                            console.error('Failed to publish UNLOCKED to front_door:', error);
                        } else {
                            console.log('Published: LOW to unlock_button');
                        }
                    });

                    enteredPassword = '';
                    passwordFeedback.textContent = 'Password Correct! Door Unlocked.';
                    passwordFeedback.style.color = 'green';
                    updateDoorStatus('Unlocked'); // Update status locally
                    doorOpenedByWeb = true; // Mark that the door was opened by the web page

                    // Close the door automatically after 2 seconds
                    setTimeout(() => {
                        doorOpenedByWeb = false; // Reset the flag after closing
                    }, 2000);
                } else {
                    passwordFeedback.textContent = 'Incorrect Password!';
                    passwordFeedback.style.color = 'red';
                    enteredPassword = '';
                }
            } else {
                enteredPassword += button.getAttribute('data-number');
            }
            passwordDisplay.textContent = enteredPassword ? '*'.repeat(enteredPassword.length) : '****';
        });
    });

    // Handle back button click to navigate back to the previous page
    backButton.addEventListener('click', () => {
        window.location.href = 'dashboard2.html'; // Update this URL to your actual home page or previous page
    });

    // Handle change password button click (Placeholder for navigation)
    changePasswordButton.addEventListener('click', () => {
        window.location.href = 'change_door_password.html'; // Update this to actual navigation if needed
    });
}

// Ensure that the door controls are initialized once the DOM is fully loaded
document.addEventListener('DOMContentLoaded', initializeDoorControl);
