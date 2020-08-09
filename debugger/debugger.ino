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
int debugPins[8];

#define CLK 3
#define RW 4

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
    Serial.print("    ");

    unsigned int debug = 0;
    for(int i=0; i<=7; i++){  // Read debug pins
        int inbit = digitalRead(debugPins[i]) ? 1 : 0;
        Serial.print(inbit);
    }

    char converted[50];
    sprintf(converted, "    %04x  %c  %02x", address, digitalRead(RW) ? 'r' : 'W', data);
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

    for(int i=0; i<=7; i++){  // Initialise address pins
        debugPins[i] = 12 - i; // Pins go 12, 11, ..., 5
        pinMode(debugPins[i], INPUT);
    }
    
    pinMode(CLK, INPUT);
    pinMode(RW, INPUT);
    attachInterrupt(digitalPinToInterrupt(CLK), pulse, RISING);
}

void loop() {
    
}
