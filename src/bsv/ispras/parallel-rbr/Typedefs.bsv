/*
 * Copyright 2022 ISP RAS (http://www.ispras.ru)
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See
 * the License for the specific language governing permissions and limitations
 * under the License.
 */

package Typedefs;

typedef 2841 W1; /* 2048*sqrt(2)*cos(1*pi/16) */
typedef 2676 W2; /* 2048*sqrt(2)*cos(2*pi/16) */
typedef 2408 W3; /* 2048*sqrt(2)*cos(3*pi/16) */
typedef 1609 W5; /* 2048*sqrt(2)*cos(5*pi/16) */
typedef 1108 W6; /* 2048*sqrt(2)*cos(6*pi/16) */
typedef 565 W7;  /* 2048*sqrt(2)*cos(7*pi/16) */
typedef 181 R2;  /* 256/sqrt(2) */

int w1 = fromInteger(valueOf(W1));
int w2 = fromInteger(valueOf(W2));
int w3 = fromInteger(valueOf(W3));
int w5 = fromInteger(valueOf(W5));
int w6 = fromInteger(valueOf(W6));
int w7 = fromInteger(valueOf(W7));
int r2 = fromInteger(valueOf(R2));

endpackage // Typedefs
