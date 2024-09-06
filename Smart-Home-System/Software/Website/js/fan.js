function initialize_fan() {
    const button = document.getElementById("fan-button");
    const speedControl = document.getElementById("speed");

    button.addEventListener("click", function() {
        if (button.textContent === "Turn Fan On") {
            button.textContent = "Turn Fan Off";
            button.classList.add("active");
        } else {
            button.textContent = "Turn Fan On";
            button.classList.remove("active");
        }
    });

    speedControl.addEventListener("input", function() {
        const value = parseInt(this.value);
        let speedLabel = "";

        switch (value) {
            case 0:
                speedLabel = "Low";
                break;
            case 1:
                speedLabel = "Mid";
                break;
            case 2:
                speedLabel = "High";
                break;
        }

        document.querySelector(".fan-speed label").textContent = `FAN SPEED: ${speedLabel}`;
    });
}

document.addEventListener('DOMContentLoaded', initialize_fan);

