// Update with your actual username and password for the MQTT broker
const options = {
    username: 'faresmohamed260', // Replace with your MQTT username
    password: '#Rmc136a1drd47r', // Replace with your MQTT password
    clean: true, // Use a clean session to avoid issues with retained topics
    reconnectPeriod: 1000, // Reconnect after 1 second if disconnected
    connectTimeout: 30 * 1000, // Timeout after 30 seconds
};

// Connect to the MQTT broker using the TLS WebSocket URL and credentials
const client = mqtt.connect('wss://7723500f166547509bc34df058860232.s1.eu.hivemq.cloud:8884/mqtt', options);

// Function to publish messages with error handling
function publishMessage(topic, message) {
    if (client.connected) {
        client.publish(topic, message, { qos: 0, retain: false }, (error) => {
            if (error) {
                console.error(`Failed to publish message to ${topic}:`, error);
            } else {
                console.log(`Published: ${message} to topic ${topic}`);
            }
        });
    } else {
        console.warn('MQTT client is not connected. Unable to publish message:', message);
    }
}

// Initialize the fan controls and MQTT connection
function initialize_fan() {
    const button = document.getElementById("fan-button");
    const speedControl = document.getElementById("speed");
    const currentSpeedDisplay = document.getElementById("current-speed"); // Feedback element for fan speed
    const backButton = document.getElementById("back-button"); // Back button element

    // Check if elements exist before using them
    if (!button || !speedControl || !currentSpeedDisplay || !backButton) {
        console.error('One or more elements are missing from the DOM.');
        return;
    }

    // MQTT Connection Event
    client.on('connect', () => {
        console.log('Connected to MQTT broker');
        currentSpeedDisplay.textContent = 'Connected to MQTT broker';
        currentSpeedDisplay.classList.add('connected');

        // Subscribe to the necessary topics including fan state and speed
        client.subscribe(['fan_state_topic', 'fan_speed'], (err) => {
            if (err) {
                console.error('Failed to subscribe to topics:', err);
            } else {
                console.log('Subscribed to fan_state_topic, and fan_speed');
            }
        });
    });

    // Error and Disconnection Handling
    client.on('error', (err) => {
        console.error('MQTT Connection Error:', err);
        currentSpeedDisplay.textContent = 'Error connecting to MQTT broker';
        currentSpeedDisplay.classList.add('error');
    });

    client.on('reconnect', () => {
        console.log('Reconnecting to MQTT broker...');
        currentSpeedDisplay.textContent = 'Reconnecting...';
        currentSpeedDisplay.classList.add('reconnecting');
    });

    client.on('close', () => {
        console.log('Disconnected from MQTT broker');
        currentSpeedDisplay.textContent = 'Disconnected from MQTT broker';
        currentSpeedDisplay.classList.add('disconnected');
    });

    // Handle incoming messages from subscribed topics
    client.on('message', (topic, message) => {
        const messageText = message.toString().toLowerCase();

        // Fan state updates from any source (web/mobile)
        if (topic === 'fan_state_topic') {
            console.log(`Received fan state update: ${messageText}`);

            // Sync button state with received message
            if (messageText === 'on') {
                button.textContent = "Turn Fan Off";
                button.classList.add("active");
                currentSpeedDisplay.textContent = 'Fan is ON'; // Update status display
            } else if (messageText === 'off') {
                button.textContent = "Turn Fan On";
                button.classList.remove("active");
                currentSpeedDisplay.textContent = 'Fan is OFF'; // Update status display
            }
        }

        // Handle speed updates from any source
        if (topic === 'fan_speed') {
            let speedLabel = messageText.toUpperCase();
            document.querySelector(".fan-speed label").textContent = `FAN SPEED: ${speedLabel}`;
            currentSpeedDisplay.textContent = `Fan is ON, Speed: ${speedLabel}`;
            console.log(`Fan speed updated to: ${speedLabel}`);
        }
    });

    // Handle button click to turn the fan on/off and sync state
    button.addEventListener("click", function () {
        if (button.textContent === "Turn Fan On") {
            publishMessage('fan_state_topic', 'on'); // Sync state across devices
            button.textContent = "Turn Fan Off";
            button.classList.add("active");
            currentSpeedDisplay.textContent = 'Fan is ON';
        } else {
            publishMessage('fan_state_topic', 'off'); // Sync state across devices
            button.textContent = "Turn Fan On";
            button.classList.remove("active");
            currentSpeedDisplay.textContent = 'Fan is OFF';
        }
    });

    // Handle fan speed change
    speedControl.addEventListener("input", function () {
        const value = parseInt(this.value);
        let speedMessage = '';

        switch (value) {
            case 0:
                speedMessage = "low";
                break;
            case 1:
                speedMessage = "medium";
                break;
            case 2:
                speedMessage = "high";
                break;
        }

        publishMessage('fan_speed', speedMessage); // Publish speed to 'fan_speed' topic
    });

    // Handle back button click to navigate back to the home page
    backButton.addEventListener("click", () => {
        window.location.href = 'dashboard2.html'; // Update the URL to your home page
    });
}

// Update the temperature graph with new data (Placeholder function, integrate with your graphing library)
function updateTemperatureGraph(tempValue) {
    // Logic to update your graph goes here, e.g., add data points to Chart.js, D3.js, etc.
    console.log(`Updating graph with temperature: ${tempValue}`);
}

// Ensure that the fan controls are initialized once the DOM is fully loaded
document.addEventListener('DOMContentLoaded', initialize_fan);
