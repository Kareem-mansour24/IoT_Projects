// Connect to the MQTT broker using secure WebSocket (wss://)
const client = mqtt.connect('wss://broker.hivemq.com:8884/mqtt'); // Ensure the broker URL and port are correct

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
        // Subscribe to door status topic and IR sensor topic
        client.subscribe('front_door', (err) => {
            if (err) {
                console.error('Failed to subscribe to front_door:', err);
            }
        });
        client.subscribe('ir_sensor', (err) => {
            if (err) {
                console.error('Failed to subscribe to ir_sensor:', err);
            }
        });
    });

    // Handle incoming messages from subscribed topics
    client.on('message', (topic, message) => {
        const messageStr = message.toString().trim().toUpperCase();

        switch (topic) {
            case 'front_door':
                doorStatus = messageStr === 'UNLOCKED' ? 'Unlocked' : 'Locked';
                updateDoorStatus(doorStatus);
                break;

            case 'ir_sensor':
                if (messageStr === 'CLEAR' && doorStatus === 'Unlocked' && !doorOpenedByWeb) {
                    // IR sensor detects no person, close the door if it was opened by hardware
                    closeDoor();
                }
                break;

            default:
                console.log(`Unhandled topic: ${topic}`);
        }
    });

    // Update door status display
    function updateDoorStatus(status) {
        doorStatusText.textContent = status;
        doorIcon.className = status === 'Unlocked' ? 'fas fa-lock-open' : 'fas fa-lock';
        doorStatusText.style.color = status === 'Unlocked' ? 'green' : 'red';
    }

    // Function to close the door
    function closeDoor() {
        doorStatus = 'Locked';
        updateDoorStatus(doorStatus);
        client.publish('door_control', 'LOCK'); // Send a lock command to close the door
        console.log('Door closed.');
    }

    // Handle number press on the keypad
    keypadButtons.forEach(button => {
        button.addEventListener('click', () => {
            if (button.id === 'clear-button') {
                enteredPassword = '';
                passwordFeedback.textContent = ''; // Clear feedback
            } else if (button.id === 'submit-button') {
                if (enteredPassword === correctPassword) {
                    client.publish('unlock_button', 'LOW'); // Send unlock command
                    enteredPassword = '';
                    passwordFeedback.textContent = 'Password Correct! Door Unlocked.';
                    passwordFeedback.style.color = 'green';
                    updateDoorStatus('Unlocked'); // Update status locally
                    doorOpenedByWeb = true; // Mark that the door was opened by the web page
                    // Close the door automatically after 2 seconds
                    setTimeout(() => {
                        closeDoor();
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
        alert('Change Password page would be navigated here.'); // Update this to actual navigation if needed
    });
}

// Ensure that the door controls are initialized once the DOM is fully loaded
document.addEventListener('DOMContentLoaded', initializeDoorControl);
