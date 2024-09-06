document.addEventListener('DOMContentLoaded', function() {
    // Select all grid items
    const gridItems = document.querySelectorAll('.grid-item');

    // Add click event listeners to each grid item
    gridItems.forEach(item => {
        item.addEventListener('click', function() {
            const target = item.getAttribute('data-target');
            // Navigate based on the data-target attribute
            switch (target) {
                case 'garage':
                    window.location.href = 'garage.html'; // Navigate to Garage page
                    break;
                case 'fan':
                    window.location.href = 'fan.html'; // Navigate to Fan page
                    break;
                case 'light':
                    window.location.href = 'light.html'; // Navigate to Light page
                    break;
                case 'fire':
                    window.location.href = 'fire.html'; // Navigate to Fire page
                    break;
                default:
                    console.error('Unknown target:', target);
            }
        });
    });
});
