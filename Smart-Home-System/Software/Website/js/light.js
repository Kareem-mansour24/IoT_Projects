function initialize_light() {
    console.log("initialize_light function called");

    const button = document.getElementById('lightButton');
    const icon = document.getElementById('lightIcon');

    if (!button || !icon) {
        console.error("Button or icon element not found");
        return;
    }

    button.addEventListener('click', function() {
        this.classList.toggle('clicked');

        if (this.classList.contains('clicked')) {
            this.textContent = 'Turn Light Off';
            icon.style.color = 'red';
        } else {
            this.textContent = 'Turn Light On';
            icon.style.color = 'green';
        }
    });
}

document.addEventListener('DOMContentLoaded', initialize_light);
