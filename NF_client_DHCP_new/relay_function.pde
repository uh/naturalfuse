void turnOutletOn(){
  if(outletOn == false){
    digitalWrite(outletOnPin,HIGH);
    delay(100);
    digitalWrite(outletOnPin,LOW);
    outletOn = true;
  }
}

void turnOutletOff(){
  if(outletOn == true){
    digitalWrite(outletOffPin,HIGH);
    delay(100);
    digitalWrite(outletOffPin,LOW);
    outletOn = false;
  }
}

void turnWaterOn(){
  if(waterOn == false){
    digitalWrite(waterOnPin,HIGH);
    delay(100);
    digitalWrite(waterOnPin,LOW);
    waterOn = true;
  }
}

void turnWaterOff(){
  if(waterOn == true){
    digitalWrite(waterOffPin,HIGH);
    delay(100);
    digitalWrite(waterOffPin,LOW);
    waterOn = false;
  }
}

void turnVinegarOn(){
  if(vinegarOn == false){
    digitalWrite(vinegarOnPin,HIGH);
    delay(100);
    digitalWrite(vinegarOnPin,LOW);
    vinegarOn = true;
  }
}

void turnVinegarOff(){
  if(vinegarOn == true){
    digitalWrite(vinegarOffPin,HIGH);
    delay(100);
    digitalWrite(vinegarOffPin,LOW);
    vinegarOn = false;
  }
}
