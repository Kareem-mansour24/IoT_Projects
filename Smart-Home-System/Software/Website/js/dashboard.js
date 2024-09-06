document.addEventListener("DOMContentLoaded", function () {
    console.log("DOMContentLoaded event fired");

    const links = document.querySelectorAll(".sidebar-icon");
    const contentArea = document.querySelector(".main-content");

    // Check if any sidebar icons are found
    if (links.length === 0) {
        console.warn("No sidebar icons found");
    }

    // Select the Sign Out button
    const signOutBtn = document.getElementById('signOutBtn');

    // Add a click event listener to the Sign Out button
    if (signOutBtn) {
        signOutBtn.addEventListener('click', function() {
            console.log("Sign Out button clicked");
            window.location.href = 'register.html'; // Ensure this path is correct
        });
    } else {
        console.warn('Sign Out button not found');
    }

    // Event listeners for sidebar links
    links.forEach((link) => {
        link.addEventListener("click", function (event) {
            event.preventDefault();
            const targetId = this.getAttribute("data-target");
            console.log(`Sidebar link clicked: ${targetId}`);
            loadContent(`${targetId}.html`);
            updateActiveLink(this);
        });
    });

    function loadContent(page) {
        console.log(`Loading content from: ${page}`);
        fetch(page)
            .then((response) => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then((html) => {
                contentArea.innerHTML = html;
                loadPageAssets(page);
            })
            .catch((error) => {
                console.error(`Error loading the ${page} content:`, error);
                contentArea.innerHTML = `<p>Error loading content. Please try again later.</p>`;
            });
    }

    function loadPageAssets(page) {
        console.log(`Loading assets for: ${page}`);
    
        // Load CSS for the page
        let cssPath = `css/${page.replace('.html', '')}.css`;
        let cssLink = document.querySelector(`link[href="${cssPath}"]`);
    
        if (!cssLink) {
            cssLink = document.createElement('link');
            cssLink.rel = 'stylesheet';
            cssLink.href = cssPath;
            document.head.appendChild(cssLink);
            console.log(`CSS loaded: ${cssPath}`);
        } else {
            console.log(`CSS already loaded: ${cssPath}`);
        }
    
        // Load JS for the page
        let existingScript = document.querySelector(`script[data-page="${page.replace('.html', '')}"]`);
        if (existingScript) {
            existingScript.remove();
        }
    
        const script = document.createElement('script');
        script.src = `js/${page.replace('.html', '')}.js`;
        script.type = 'text/javascript';
        script.dataset.page = page.replace('.html', '');
        script.defer = true;
        script.onload = () => {
            console.log(`Script loaded and executed: ${script.src}`);

            const initFunctionName = `initialize_${page.replace('.html', '')}`;
            if (typeof window[initFunctionName] === "function") {
                console.log(`Calling function: ${initFunctionName}`);
                window[initFunctionName]();
            }
        };
        script.onerror = () => {
            console.error(`Error loading script: ${script.src}`);
        };
        document.body.appendChild(script);
    }

    function updateActiveLink(activeLink) {
        links.forEach((link) => {
            link.classList.remove("active");
        });
        activeLink.classList.add("active");
    }

    // Initial load of home content
    loadContent('home.html'); // Load home content just like any other page
});
