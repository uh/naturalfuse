#include <Ethernet.h>
#include "Dhcp.h"

#include <string.h>

byte mac[] = { 
  0xDA, 0xAD, 0xCA, 0xEF, 0xFE, 0xEE };
//byte server[] = { 
// 64, 233, 187, 99 }; // Google
byte server [] = {
  209, 40, 205, 190
};// pachube.com
boolean ipAcquired = false;
boolean connected = false;
boolean reading = false;

Client client(server, 80);

int content_length;
int successes = 0;
int failures = 0;

void setup()
{
  randomSeed(analogRead(5));
  mac[5] = byte(random(255));

  Serial.begin(9600);
  Serial.println("getting ip...");
  digitalWrite(13, HIGH);
  int result = Dhcp.beginWithDHCP(mac);
  Serial.println("got result...");
  digitalWrite(13, LOW);
  Serial.println(result);

  if(result == 1)
  {
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

void loop()
{

  if (!connected){

    Serial.println("connecting...");

    if (client.connect()) {
      Serial.println("connected");

      int analog0 = analogRead(0);
      int analog1 = analogRead(1);
      int analog2 = analogRead(2);
      int analog3 = analogRead(3);

      int content_length = length(analog0) + length(analog1) + length(analog2) + length(analog3) + 4 + length(successes);

      client.println("GET /api/feeds/504.csv HTTP/1.1");
      client.println("Host: www.pachube.com");
      client.println("X-PachubeApiKey: ENTERAPIKEY");
      client.println();


      client.println("PUT /api/feeds/2411.csv HTTP/1.1");
      client.println("Host: www.pachube.com");
      client.println("X-PachubeApiKey: ENTERAPIKEY");

      client.println("User-Agent: Arduino (Pachube DHCP v0.1)");
      client.print("Content-Type: text/csv\nContent-Length: ");
      client.println(content_length);
      client.println("Connection: close");
      client.println();

      client.print(analog0);
      client.print(",");
      client.print(analog1);
      client.print(",");
      client.print(analog2);
      client.print(",");
      client.print(analog3);
      client.print(",");
      client.print(successes);
      client.println();
      connected = true;
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
