document.addEventListener('DOMContentLoaded', function () {
    console.log('Home page DOM fully loaded and parsed');

    const temperatureDisplay = document.querySelector('.weather-info p'); // Assuming the temperature display is within .weather-info
    const gridItems = document.querySelectorAll('.grid-item');

    if (!temperatureDisplay) {
        console.error('Temperature display element is missing from the DOM.');
        return;
    }

    // Update with your actual username and password for the MQTT broker
    const options = {
        username: 'faresmohamed260', // Replace with your MQTT username
        password: '#Rmc136a1drd47r', // Replace with your MQTT password
        clean: true, // Use a clean session to avoid issues with retained topics
        reconnectPeriod: 1000, // Reconnect after 1 second if disconnected
        connectTimeout: 30 * 1000, // Timeout after 30 seconds
    };

    // Connect to the MQTT broker using secure WebSocket (wss://)
    const client = mqtt.connect('wss://836d265158fe407b82c0c60afc009fad.s1.eu.hivemq.cloud:8884/mqtt', options); // Ensure the broker URL and port are correct

    // MQTT Connection Event
    client.on('connect', () => {
        console.log('Connected to MQTT broker');
        client.subscribe('dht', (err) => {
            if (err) {
                console.error('Failed to subscribe to dht:', err);
            }
        });
    });

    // Handle incoming messages from subscribed topics
    client.on('message', (topic, message) => {
        if (topic === 'dht') {
            const tempValue = parseFloat(message.toString().trim());
            if (!isNaN(tempValue)) {
                temperatureDisplay.textContent = `${tempValue.toFixed(1)}°C Outdoor temperature`;
            }
        }
    });

    // Handle grid item clicks
    gridItems.forEach(item => {
        item.addEventListener('click', function() {
            const target = item.getAttribute('data-target');
            switch (target) {
                case 'fan':
                    window.location.href = 'fan.html';
                    break;
                case 'light':
                    window.location.href = 'light.html';
                    break;
                case 'door':
                    window.location.href = 'door.html';
                    break;
                case 'alarm':
                    window.location.href = 'alarm.html';
                    break;
                case 'pool':
                    window.location.href = 'pool.html';
                    break;
                case 'solar':
                    window.location.href = 'solar.html';
                    break;
                default:
                    console.error('Unknown target:', target);
            }
        });
    });
});
