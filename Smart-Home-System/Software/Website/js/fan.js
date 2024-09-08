// Connect to the MQTT broker using secure WebSocket (wss://)
const client = mqtt.connect('wss://broker.hivemq.com:8884/mqtt'); // Ensure the broker URL and port are correct

// Initialize the fan controls and MQTT connection
function initialize_fan() {
    const button = document.getElementById("fan-button");
    const speedControl = document.getElementById("speed");
    const currentSpeedDisplay = document.getElementById("current-speed"); // Feedback element for fan speed
    const temperatureDisplay = document.getElementById("temperature-value"); // Element to display temperature
    const backButton = document.getElementById("back-button"); // Back button element

    // Check if elements exist before using them
    if (!button || !speedControl || !currentSpeedDisplay || !temperatureDisplay || !backButton) {
        console.error('One or more elements are missing from the DOM.');
        return;
    }

    // MQTT Connection Event
    client.on('connect', () => {
        console.log('Connected to MQTT broker');
        currentSpeedDisplay.textContent = 'Connected to MQTT broker';
        currentSpeedDisplay.classList.add('connected');

        // Subscribe to the 'dht' topic for temperature updates
        client.subscribe('dht', (err) => {
            if (err) {
                console.error('Failed to subscribe to the dht topic:', err);
            } else {
                console.log('Subscribed to the dht topic');
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
        if (topic === 'dht') {
            const tempValue = parseFloat(message.toString());
            console.log(`Received temperature: ${tempValue}°C`);
            temperatureDisplay.textContent = `${tempValue}°`; // Update the temperature display
            updateTemperatureGraph(tempValue); // Call function to update graph with the new temperature
        }
    });

    // Handle button click to turn the fan on/off
    button.addEventListener("click", function () {
        if (button.textContent === "Turn Fan On") {
            button.textContent = "Turn Fan Off";
            button.classList.add("active");
            client.publish('fan_power', 'LOW'); // Publish the "low" state when turning on
            console.log('Published: LOW to topic fan_power');
            currentSpeedDisplay.textContent = 'Fan is ON, Speed: Low'; // Display current state
        } else {
            button.textContent = "Turn Fan On";
            button.classList.remove("active");
            client.publish('fan_power', 'LOW'); // Publish "off" when turning off
            console.log('Published: LOW to topic fan_power');
            currentSpeedDisplay.textContent = 'Fan is OFF'; // Display off state
        }
    });

    // Handle fan speed change
    speedControl.addEventListener("input", function () {
        const value = parseInt(this.value);
        let speedLabel = "";
        let speedMessage = "";

        switch (value) {
            case 0:
                speedLabel = "LOW";
                speedMessage = "LOW"; // Publish "low" when speed is set to low
                break;
            case 1:
                speedLabel = "MEDIUM";
                speedMessage = "MEDIUM"; // Publish "mid" when speed is set to mid
                break;
            case 2:
                speedLabel = "HIGH";
                speedMessage = "HIGH"; // Publish "high" when speed is set to high
                break;
        }

        document.querySelector(".fan-speed label").textContent = `FAN SPEED: ${speedLabel}`;
        currentSpeedDisplay.textContent = `Fan is ON, Speed: ${speedLabel}`; // Update current speed display
        client.publish('fan_speed', speedMessage); // Publish speed to 'fan_speed' topic
        console.log(`Published: ${speedMessage} to topic fan_speed`);
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
