//I've been using Zombie_3_6_RC in Processing to interact.
// Record any errors that may occur in the compass.
int error = 0;

//int pwm_a = 10; //PWM control for motor outputs 1 and 2 is on digital pin 10
int pwm_a = 3;  //PWM control for motor outputs 1 and 2 is on digital pin 3
int pwm_b = 11;  //PWM control for motor outputs 3 and 4 is on digital pin 11
int dir_a = 12;  //dir control for motor outputs 1 and 2 is on digital pin 12
int dir_b = 13;  //dir control for motor outputs 3 and 4 is on digital pin 13

int lowspeed = 120;
int highspeed = 140;

//Distance away
int distance;

//Sets the duration each keystroke captures the motors.
int keyDuration = 10;

int iComp;

char parseStream[3];
int parseStreamIndex = 0;

int motorPwmA;
int motorPwmB;

boolean motorDirA;
boolean motorDirB;

void setup()
{
  Serial.begin(115200);
  delay(100);
  Serial.println("Connected correctly...");

  pinMode(pwm_a, OUTPUT);  //Set control pins to be outputs
  pinMode(pwm_b, OUTPUT);
  pinMode(dir_a, OUTPUT);
  pinMode(dir_b, OUTPUT);
  
  analogWrite(pwm_a, 0);        
  //set both motors to run at (100/255 = 39)% duty cycle (slow)  
  analogWrite(pwm_b, 0);

  pinMode (2,OUTPUT);//attach pin 2 to vcc
  pinMode (5,OUTPUT);//attach pin 5 to GND
  // initialize serial communication:

  
}

void loop()
{

  delay(10); //For serial stability.
  
  char val = Serial.read();// - '0';
   
   parseStream[parseStreamIndex] = val;
   
   if(val > -1)
   {
     if(val == ':')
     {
        int int1 = parseStream[0];
        int int2 = parseStream[1];
        int int3 = parseStream[2];
        int int4 = parseStream[3];
        
        if (int4 == 58){
            // CONTROL BYTE
            //  BIT: 7=CAN'T BE USED
            //  BIT: 6=
            //  BIT: 5=Breaklights ON
            //  BIT: 4=Headlights ON
            //  BIT: 3=127+ MOTOR B
            //  BIT: 2=127+ MOTOR A
            //  BIT: 1=MOTOR B DIR
            //  BIT: 0=MOTOR A DIR
          
          if ((bitRead(int1, 0)) == 1)
          {
           //Serial.print(" A Forward "); 
           motorDirA = true;
          }
          if ((bitRead(int1, 1)) == 1)
          {
           //Serial.print(" B Forward "); 
           motorDirB = true;
          }
          if ((bitRead(int1, 2)) == 1)
          {
            int2 = int2 + 127;
          }
          if ((bitRead(int1, 3)) == 1)
          {
            int3 = int3 + 127;
          }
          /*
          Serial.print("One: ");
          Serial.print(int1);
          Serial.print(" Two: ");
          Serial.print(int2);
          Serial.print(" Three: ");
          Serial.print(int3);
          Serial.print(" Four: ");
          Serial.println(int4);
         */
         Serial.write(0x06);
          motorPwmA = int2;
          motorPwmB = int3;
          
          drive();
          //delay(10);
          motorDirA = false;
          motorDirB = false;
        }
          parseStreamIndex = -1;               
     }
     parseStreamIndex++;
   }
}   

//boolean motorDirA, boolean motorDirB, int motorPwmA, int motorPwmB

void drive(){
//Straight back
      analogWrite(pwm_a, motorPwmA);      
      analogWrite(pwm_b, motorPwmB);
  
      digitalWrite(dir_a, motorDirA);  //Reverse motor direction, 1 high, 2 low
      digitalWrite(dir_b, motorDirB);  //Reverse motor direction, 3 low, 4 high
      while(Serial.read() != -1 );
//delay(keyDuration);
}


