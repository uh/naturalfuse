#include <Ethernet.h>
#include "Dhcp.h"

#include <string.h>

byte mac[] = { 0xDA, 0xAD, 0xCA, 0xEF, 0xFE, 0xEE };

byte server [] = {209, 40, 205, 190
};

boolean ipAcquired = false;
boolean connected = false;
boolean reading = false;
#define REMOTE_FEED_DATASTREAMS    6
float remoteSensor[REMOTE_FEED_DATASTREAMS];   

//1//
// variable for extract function
/*char pachube_data[80];
char buff[64];
char *found;
int pointer = 0;
boolean found_status_200 = false;
boolean found_session_id = false;
boolean found_CSV = false;
boolean found_content = false;
*/

Client client(server, 80);

//analog in
int humidPin = 1;    
int lightPin = 2;
int switchPin = 0;
int waterA = 3; 
int waterB = 4;

//digital in
int ledPin = 8;     
int outletOnPin = 2;
int outletOffPin = 3;
int waterOnPin = 6;
int waterOffPin = 7;
int vinegarOnPin = 4;
int vinegarOffPin = 5;

int sensorValue = 0;  // variable to store the value coming from the sensor
int switchValue = 0;
int wAValue = 0;
int wBValue = 0;
int humid = 0;
int lightValue = 0;

int content_length;
int successes = 0;
int failures = 0;

void setup(){
  
  pinMode(ledPin, OUTPUT); 
  pinMode(outletOnPin, OUTPUT); 
  pinMode(outletOffPin, OUTPUT);
  pinMode(waterOnPin, OUTPUT);
  pinMode(waterOffPin, OUTPUT); 
  pinMode(vinegarOnPin, OUTPUT);
  pinMode(vinegarOffPin, OUTPUT); 
  
  randomSeed(analogRead(5));
  mac[5] = byte(random(255));

  Serial.begin(9600);
  Serial.println("getting ip...");
  digitalWrite(13, HIGH);
  int result = Dhcp.beginWithDHCP(mac);
  Serial.println("got result...");
  digitalWrite(13, LOW);
  Serial.println(result);

  if(result == 1){
    ipAcquired = true;

    //byte buffer[6];
    Serial.println("ip acquired...");

    //Dhcp.getMacAddress(buffer);
    //Serial.print("mac address: ");
    //printArray(&Serial, ":", buffer, 6, 16);
    /*
    Dhcp.getLocalIp(buffer);
    Serial.print("ip address: ");
    printArray(&Serial, ".", buffer, 4, 10);

    Dhcp.getSubnetMask(buffer);
    Serial.print("subnet mask: ");
    printArray(&Serial, ".", buffer, 4, 10);

    Dhcp.getGatewayIp(buffer);
    Serial.print("gateway ip: ");
    printArray(&Serial, ".", buffer, 4, 10);

    Dhcp.getDhcpServerIp(buffer);
    Serial.print("dhcp server ip: ");
    printArray(&Serial, ".", buffer, 4, 10);

    Dhcp.getDnsServerIp(buffer);
    Serial.print("dns server ip: ");
    printArray(&Serial, ".", buffer, 4, 10);

    delay(3000);
    */
  }
  else
    Serial.println("unable to acquire ip address...");
}

void printArray(Print *output, char* delimeter, byte* data, int len, int base)
{
  char buf[10] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0        };

  for(int i = 0; i < len; i++)
  {
    if(i != 0)
      output->print(delimeter);

    output->print(itoa(data[i], buf, base));
  }

  output->println();
}

void loop(){
//2//    
//  while (reading){
//      while (client.available()) {
//        checkForResponse();
//      } 
//    }

  if (!connected){

    Serial.println("connecting...");

    if (client.connect()) {
      Serial.println("connected");
      
      //check these sensors everytime its connected
      sensorValue = analogRead(humidPin); 
      
      if(analogRead(switchPin) <= 250){switchValue = 0;} 
      if(analogRead(switchPin) < 700 && analogRead(switchPin) > 250){switchValue = 1;} 
      if(analogRead(switchPin) >= 700){switchValue = 2;} 
      
      if(analogRead(waterA) > 10){wAValue = 1;}else{wAValue = 0;}
      if(analogRead(waterB) > 10){wBValue = 1;}else{wBValue = 0;}
      
      lightValue = analogRead(lightPin);
      humid = 50 + (sensorValue/12);  
      if (humid >= 100){humid = 100;}



      int content_length = length(humid) + length(lightValue) + length(wAValue) + length(wBValue) + length(switchValue) + 4;

      client.println("GET /api/feeds/504.csv HTTP/1.1");
      client.println("Host: www.pachube.com");
      client.println("X-PachubeApiKey: d80239e6a4f906ce4674dacb3534ae7c996db91c5a510e93194b277cc4fe140c");
      client.println();


      client.println("PUT /api/feeds/2304.csv HTTP/1.1");
      client.println("Host: www.pachube.com");
      client.println("X-PachubeApiKey: d80239e6a4f906ce4674dacb3534ae7c996db91c5a510e93194b277cc4fe140c");

      client.println("User-Agent: Arduino (Pachube DHCP v0.1)");
      client.print("Content-Type: text/csv\nContent-Length: ");
      client.println(content_length);
      client.println("Connection: close");
      client.println();

      //client.print("1,7");
      client.print(humid);
      client.print(",");
      client.print(lightValue);
      client.print(",");
      client.print(wAValue);
      client.print(",");
      client.print(wBValue);
      client.print(",");
      client.print(switchValue);

      
      client.println();
      connected = true;
      reading = true;
      successes++;
    } 
    else {
      Serial.println("connection failed");
    }

  } 
  else {

    if(ipAcquired)
    {
      if (client.available()) {
        char c = client.read();
        
          digitalWrite(13, HIGH);

        Serial.print(c);
          digitalWrite(13, LOW);

      }

      if (!client.connected()) {
        Serial.println();
        Serial.println("disconnecting.");
        reading = false;
        client.stop();
        connected = false;
          digitalWrite(13, HIGH);

        delay(20000);
          digitalWrite(13, LOW);

        //spinForever();
      }
    }
  }
}

int length(int in){
  int r;
  if (in > 9999) r = 5;
  else if (in > 999) r = 4;
  else if (in > 99) r = 3;
  else if (in > 9) r = 2;
  else r = 1;
  return r;
}

//3//
// extract content function
/*void checkForResponse(){  
  char c = client.read();
  //Serial.print(c);
  buff[pointer] = c;
  if (pointer < 64) pointer++;
  if (c == '\n') {
    found = strstr(buff, "200 OK");
    if (found != 0){
      found_status_200 = true; 
      //Serial.println("Status 200");
    }
    buff[pointer]=0;
    found_content = true;
    clean_buffer();    
  }

  if ((found_session_id) && (!found_CSV)){
    found = strstr(buff, "HTTP/1.1");
    if (found != 0){
      char csvLine[strlen(buff)-9];
      strncpy (csvLine,buff,strlen(buff)-9);

      //Serial.println("This is the retrieved CSV:");     
      //Serial.println("---");     
      //Serial.println(csvLine);
      //Serial.println("---");   
      Serial.println("\n--- updated: ");
      Serial.println(pachube_data);
      Serial.println("\n--- retrieved: ");
      char delims[] = ",";
      char *result = NULL;
      char * ptr;
      result = strtok_r( buff, delims, &ptr );
      int counter = 0;
      while( result != NULL ) {
        remoteSensor[counter++] = atof(result); 
        result = strtok_r( NULL, delims, &ptr );
      }  
      for (int i = 0; i < REMOTE_FEED_DATASTREAMS; i++){
        Serial.print( (int)remoteSensor[i]); // because we can't print floats
        Serial.print("\t");
      }

      found_CSV = true;

      Serial.print("\nsuccessful updates=");
      Serial.println(++successes);

    }
  }

  if (found_status_200){
    found = strstr(buff, "_id=");
    if (found != 0){
      clean_buffer();
      found_session_id = true; 
    }
  }
}
void clean_buffer() {
  pointer = 0;
  memset(buff,0,sizeof(buff)); 
}
*/
