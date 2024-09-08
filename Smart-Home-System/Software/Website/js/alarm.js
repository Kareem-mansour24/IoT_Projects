// Connect to the MQTT broker using secure WebSocket (wss://)
const client = mqtt.connect('wss://broker.hivemq.com:8884/mqtt'); // Ensure the broker URL and port are correct

// Initialize the alarm controls and MQTT connection
function initializeAlarmSystem() {
    const temperatureDisplay = document.getElementById('temperature-value');
    const fireAlarmStatus = document.getElementById('fire-alarm-status');
    const motionSensorStatus = document.getElementById('motion-sensor-status');
    const resetButton = document.getElementById('reset-button');
    const backButton = document.getElementById('back-button'); // Back button element

    // Ensure all elements are found before proceeding
    if (!temperatureDisplay || !fireAlarmStatus || !motionSensorStatus || !resetButton || !backButton) {
        console.error('One or more elements are missing from the DOM.');
        return;
    }

    // MQTT Connection Event
    client.on('connect', () => {
        console.log('Connected to MQTT broker');
        // Subscribe to relevant topics
        client.subscribe('fire_alarm', (err) => {
            if (err) {
                console.error('Failed to subscribe to fire_alarm:', err);
            }
        });
        client.subscribe('security_alarm', (err) => {
            if (err) {
                console.error('Failed to subscribe to security_alarm:', err);
            }
        });
        client.subscribe('dht', (err) => {
            if (err) {
                console.error('Failed to subscribe to dht:', err);
            }
        });
    });

    // Handle incoming messages from subscribed topics
    client.on('message', (topic, message) => {
        const messageStr = message.toString().trim().toUpperCase();

        switch (topic) {
            case 'fire_alarm':
                // Update fire alarm status based on message
                if (messageStr === 'LOW') {
                    fireAlarmStatus.classList.add('active');
                    fireAlarmStatus.querySelector('.status').textContent = 'Active';
                } else {
                    fireAlarmStatus.classList.remove('active');
                    fireAlarmStatus.querySelector('.status').textContent = 'Inactive';
                }
                break;

            case 'security_alarm':
                // Update motion sensor status based on message
                if (messageStr === 'LOW') {
                    motionSensorStatus.classList.add('active');
                    motionSensorStatus.querySelector('.status').textContent = 'Active';
                } else {
                    motionSensorStatus.classList.remove('active');
                    motionSensorStatus.querySelector('.status').textContent = 'Inactive';
                }
                break;

            case 'dht':
                // Update temperature display
                const tempValue = parseFloat(messageStr);
                if (!isNaN(tempValue)) {
                    temperatureDisplay.textContent = `${tempValue.toFixed(1)}°`;
                }
                break;

            default:
                console.log(`Unhandled topic: ${topic}`);
        }
    });

    // Handle reset button click to reset sensors
    resetButton.addEventListener('click', () => {
        client.publish('online_reset_button', 'LOW'); // Publish reset command
        fireAlarmStatus.classList.remove('active');
        motionSensorStatus.classList.remove('active');
        fireAlarmStatus.querySelector('.status').textContent = 'Inactive';
        motionSensorStatus.querySelector('.status').textContent = 'Inactive';
        console.log('Reset command sent successfully');
    });

    // Handle back button click to navigate back to the previous page
    backButton.addEventListener('click', () => {
        window.location.href = 'dashboard2.html'; // Update this URL to your actual home page or previous page
    });
}

// Ensure that the alarm system controls are initialized once the DOM is fully loaded
document.addEventListener('DOMContentLoaded', initializeAlarmSystem);
