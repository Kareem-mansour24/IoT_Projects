function initialize_fire() {
    const button = document.getElementById('sensorButton');
    const icon = document.getElementById('fireIcon');

    button.addEventListener('click', function() {
        // Toggle 'clicked' class on the button
        this.classList.toggle('clicked');

        // Change button text and icon color based on state
        if (this.classList.contains('clicked')) {
            this.textContent = 'Turn Sensor Off';
            icon.style.color = 'green'; // Change icon color to indicate sensor is on
        } else {
            this.textContent = 'Turn Sensor On';
            icon.style.color = '#f44336'; // Change icon color back to fire red
        }
    });
}

document.addEventListener('DOMContentLoaded', initialize_fire);
