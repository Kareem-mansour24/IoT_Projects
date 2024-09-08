const express = require('express');
const path = require('path');
const mqtt = require('mqtt');

const app = express();
const port = 5500; // Update the port number to 5500

// Serve static files from your desired directory (e.g., 'Website')
app.use(express.static(path.join(__dirname, '../Website')));

// MQTT setup (use your broker URL)
const client = mqtt.connect('mqtt://broker.hivemq.com');

client.on('connect', () => {
  console.log('Connected to MQTT broker');
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
