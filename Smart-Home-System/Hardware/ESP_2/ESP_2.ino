#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <LiquidCrystal_I2C.h>
#include <DHT.h>
#include <DHT_U.h>

// Wi-Fi credentials
const char* ssid = "Orange-fares";
const char* password = "rmc136a1drd47r";

// MQTT Broker settings
const char* mqtt_server = "836d265158fe407b82c0c60afc009fad.s1.eu.hivemq.cloud";
const char* mqtt_username = "faresmohamed260";
const char* mqtt_password = "#Rmc136a1drd47r";
const int mqtt_port = 8883;

// Certificates for secure connection
static const char* root_ca PROGMEM = R"EOF(
-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----
)EOF";

// Define topics
const char* fire_alarm_topic = "fire_alarm";
const char* security_alarm_topic = "security_alarm";
const char* online_reset_button_topic = "online_reset_button";
const char* dht_topic = "dht";

// Variables to hold alarm states
bool fireAlarmTriggered = false;
bool securityAlarmTriggered = false;
bool WiFiConnected = false;
bool MQTTConnected = false;

// Pin Definitions
#define FLAME_SENSOR_PIN 4
#define SMOKE_SENSOR_PIN 13
#define LED_PIN_FIRE 14
#define TRIG_PIN 5
#define ECHO_PIN 18
#define LED_PIN_SECURITY 27
#define BUZZER_PIN 19
#define DHTPIN 15
#define DHTTYPE DHT11

// Create a DHT object
DHT dht(DHTPIN, DHTTYPE);

// Initialize the LCD
LiquidCrystal_I2C lcd(0x27, 16, 2); // 16 columns and 2 rows

// MQTT client and Wi-Fi client
WiFiClientSecure espClient;
PubSubClient client(espClient);

// Task handles
TaskHandle_t fireAlarmTaskHandle = NULL;
TaskHandle_t securityAlarmTaskHandle = NULL;
TaskHandle_t onlineResetButtonTaskHandle = NULL;
TaskHandle_t DHTTaskHandle = NULL;

// Function prototypes
void setup_wifi();
void reconnect();
void callback(char* topic, byte* payload, unsigned int length);

void setup() {
  Serial.begin(115200);

  // Initialize the DHT sensor
  dht.begin();

  // Initialize pins
  pinMode(FLAME_SENSOR_PIN, INPUT);
  pinMode(SMOKE_SENSOR_PIN, INPUT);
  pinMode(ECHO_PIN, INPUT);

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(LED_PIN_FIRE, OUTPUT);
  pinMode(LED_PIN_SECURITY, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  // Initialize all LEDs and Buzzer as OFF
  digitalWrite(LED_PIN_FIRE, LOW);
  digitalWrite(LED_PIN_SECURITY, LOW);
  digitalWrite(BUZZER_PIN, LOW);

  // Initialize the LCD
  lcd.init(); 
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("Initializing...");

  // Connect to Wi-Fi
  setup_wifi();

  // Set MQTT server and callback function
  espClient.setCACert(root_ca);
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);

  // Create FreeRTOS tasks to handle LEDs based on MQTT messages
  xTaskCreatePinnedToCore(fireAlarmTask, "Fire Alarm Task", 10000, NULL, 1, &fireAlarmTaskHandle, 1);
  xTaskCreatePinnedToCore(securityAlarmTask, "Security Alarm Task", 10000, NULL, 1, &securityAlarmTaskHandle, 1);
  xTaskCreatePinnedToCore(onlineResetButtonTask, "Online Reset Button Task", 10000, NULL, 1, &onlineResetButtonTaskHandle, 1);
  xTaskCreatePinnedToCore(DHTTask, "DHT Task", 10000, NULL, 1, &DHTTaskHandle, 1);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("WiFi: ");
  lcd.print(WiFiConnected ? "Connected" : "Failed");

  lcd.setCursor(0, 1);
  lcd.print("MQTT: ");
  lcd.print(MQTTConnected ? "Connected" : "Failed");


  delay(1000);  // Adjust delay as needed
}

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  WiFiConnected = true;
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect("ESP32Client", mqtt_username, mqtt_password)) {
      Serial.println("connected");
      MQTTConnected = true;

      // Subscribe to topics
      client.subscribe(online_reset_button_topic);

    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      MQTTConnected = false;
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  Serial.println(message);

  // Send the received message to the corresponding task
  if (String(topic) == online_reset_button_topic && message == "LOW") {
    xTaskNotifyGive(onlineResetButtonTaskHandle);  // Use task notification for Online Reset button
  }
}

// Task for Fire Alarm
void fireAlarmTask(void *parameter) {
  while (1) {
      if (!fireAlarmTriggered && (digitalRead(FLAME_SENSOR_PIN) == LOW || digitalRead(SMOKE_SENSOR_PIN) == LOW)) {
      // Publish sensor state to MQTT topics
      if (client.publish(fire_alarm_topic, "LOW", true)) {
        Serial.println("Fire Alarm state published successfully.");
      } else {
        Serial.println("Failed to publish Fire Alarm state.");
      }
      fireAlarmTriggered = true;
      int *ledPinPtr = new int(LED_PIN_FIRE);
      xTaskCreate(pulseAlarmTask, "Fire Alarm Task", 10000, ledPinPtr, 1, &fireAlarmTaskHandle);
      Serial.println("Fire Alarm triggered!");
    }
    vTaskDelay(100 / portTICK_PERIOD_MS);  // Delay to avoid spamming
  }
}

// Function to measure distance using the ultrasonic sensor
long measureDistance() {
  // Send a 10us pulse to the trig pin
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // Read the echo pin and calculate the distance
  long duration = pulseIn(ECHO_PIN, HIGH);
  long distance = (duration * 0.034) / 2; // Convert to distance in cm
  //Serial.print("distance: ");
  //Serial.println(distance);
  return distance;
}

// Task for Security Alarm
void securityAlarmTask(void *parameter) {
  while (1) {
    long distance = measureDistance();
    if (!securityAlarmTriggered && distance < 50 && distance > 0) {
      // Publish sensor state to MQTT topics
      if (client.publish(security_alarm_topic, "LOW", true)) {
        Serial.println("Security Alarm state published successfully.");
      } else {
        Serial.println("Failed to publish Security Alarm state.");
      }
      securityAlarmTriggered = true;
      int *ledPinPtr = new int(LED_PIN_SECURITY);
      xTaskCreate(pulseAlarmTask, "Security Pulse Alarm Task", 10000, ledPinPtr, 1, &securityAlarmTaskHandle);
      Serial.println("Security Alarm triggered!");
    }
    vTaskDelay(500 / portTICK_PERIOD_MS);  // Delay to avoid spamming
  }
}

// Task for pulsing LED and Buzzer
void pulseAlarmTask(void *parameter) {
  int ledPin = *(int *)parameter;

  while (1) {
    if (fireAlarmTriggered || securityAlarmTriggered) {
      digitalWrite(ledPin, HIGH);
      digitalWrite(BUZZER_PIN, HIGH);
      vTaskDelay(500 / portTICK_PERIOD_MS);  // LED and Buzzer ON for 500ms

      digitalWrite(ledPin, LOW);
      digitalWrite(BUZZER_PIN, LOW);
      vTaskDelay(500 / portTICK_PERIOD_MS);  // LED and Buzzer OFF for 500ms
    } else {
      vTaskDelete(NULL);  // Delete this task when the alarm is not triggered
    }
  }
}

void onlineResetButtonTask(void *parameter) {
  while (1) {
    ulTaskNotifyTake(pdTRUE, portMAX_DELAY);  // Wait for the notification
    turnOffAlarms();
  }
}

void turnOffAlarms() {
  fireAlarmTriggered = false;
  securityAlarmTriggered = false;

  // Delete active alarm tasks
  if (fireAlarmTaskHandle != NULL) {
    vTaskDelete(fireAlarmTaskHandle);
    fireAlarmTaskHandle = NULL;
  }
  if (securityAlarmTaskHandle != NULL) {
    vTaskDelete(securityAlarmTaskHandle);
    securityAlarmTaskHandle = NULL;
  }

  // Turn off all LEDs and Buzzer
  digitalWrite(LED_PIN_FIRE, LOW);
  digitalWrite(LED_PIN_SECURITY, LOW);
  digitalWrite(BUZZER_PIN, LOW);
}

void DHTTask(void *parameter) {
  while (1) {
    // Read humidity and temperature
    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();
    String temperatureString = String(temperature);  // Convert float to String
    
    // Check if any reads failed and exit the loop if they did
    if (isnan(humidity) || isnan(temperature)) {
      Serial.println("Failed to read from DHT sensor!");
    } else {
      // Publish sensor state to MQTT topics
      if (client.publish(dht_topic, temperatureString.c_str(), true)) {
        Serial.println("Reading published successfully.");
      } else {
        Serial.println("Failed to publish reading.");
      }
    }

    // Delay for a period (e.g., 30 seconds)
    vTaskDelay(pdMS_TO_TICKS(30000));
  }
}
