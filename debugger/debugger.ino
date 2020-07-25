/**
 * Arduino debugger for the 6502 chip.
 * Credits to Ben Eater for the code structure (I have written the code myself basing it off the algorithm provided by Ben)
 * 
 *  Copyright (C) 2020 PixelSergey
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

int addressPins[16];
int dataPins[8];

#define CLK 3
#define RW 4

#define DB1 5
#define DB2 6
#define DB3 7

void pulse(){
    unsigned int address = 0;
    for(int i=0; i<=15; i++){  // Read address pins
        int inbit = digitalRead(addressPins[i]) ? 1 : 0;
        Serial.print(inbit);
        address = (address << 1) + inbit;
    }
    Serial.print("    ");
    
    unsigned int data = 0;
    for(int i=0; i<=7; i++){  // Read data pins
        int inbit = digitalRead(dataPins[i]) ? 1 : 0;
        Serial.print(inbit);
        data = (data << 1) + inbit;
    }

    char converted[50];
    sprintf(converted, "    %04x  %c  %02x    DB1:%c DB2:%c DB3:%c", address, digitalRead(RW) ? 'r' : 'W', data, digitalRead(DB1) ? 'H' : 'l', digitalRead(DB2) ? 'H' : 'l', digitalRead(DB3) ? 'H' : 'l');
    Serial.print(converted);
    Serial.println();
}

void setup() {
    Serial.begin(57600);
    
    for(int i=0; i<=15; i++){  // Initialise address pins
        addressPins[i] = 52 - 2*i; // Pins go 52, 50, ..., 22
        pinMode(addressPins[i], INPUT);
    }
    
    for(int i=0; i<=7; i++){  // Initialise data pins
        dataPins[i] = 45 - 2*i;  // Pins go 45, 43, ..., 31
        pinMode(dataPins[i], INPUT);
    }
    
    pinMode(CLK, INPUT);
    pinMode(RW, INPUT);
    pinMode(DB1, INPUT);
    pinMode(DB2, INPUT);
    pinMode(DB3, INPUT);

    attachInterrupt(digitalPinToInterrupt(CLK), pulse, RISING);
}

void loop() {
    
}
