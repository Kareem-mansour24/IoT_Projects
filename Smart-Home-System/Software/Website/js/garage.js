function initialize_garage() {
    const buttons = document.querySelectorAll('.control-button');

    buttons.forEach(button => {
        button.addEventListener('click', function() {
            // Toggle 'clicked' class on the clicked button
            this.classList.toggle('clicked');
        });
    });
}


document.addEventListener('DOMContentLoaded', initialize_garage);
