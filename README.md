# ST BLE StarNet

This repository contains the ST BLE StarNet app source code.

The ST BLE StarNet App is a companion tool to be used in conjunction with the ST’s [FP-NET-BLESTAR1](http://www.st.com/content/st_com/en/products/embedded-software/mcus-embedded-software/stm32-embedded-software/stm32-ode-function-pack-sw/fp-net-blestar1.html) function pack. It is designed to connect to a Bluetooth® Low Energy (BLE) device, acting as Central Node of a star-topology BLE network, to show data coming from and to send commands to all BLE Peripheral Nodes belonging to the BLE star network.
The [FP-NET-BLESTAR1](http://www.st.com/content/st_com/en/products/embedded-software/mcus-embedded-software/stm32-embedded-software/stm32-ode-function-pack-sw/fp-net-blestar1.html) function pack is an [STM32 ODE](http://st.com/stm32ode) Function Pack including drivers and application examples running on the STM32 microcontroller for leveraging the functionalities provided by the X-NUCLEO-IDB05A1, a BLE STM32 Nucleo expansion board, and the X-NUCLEO-IDW01M1, a Wi-Fi STM32 Nucleo expansion board.
Simply launch the ST SensNet App, scan the network and establish a Bluetooth connection with your STM32 Nucleo, appearing with name BLESTAR1, from the discovered devices list.
After connecting, the screen will populate with all data coming from the BLE devices belonging to the BLE star network.

The application is built on top of BlueST SDK, a library that provides an implementation of BlueST protocol and helps to easily export the data via Bluetooth® Low Energy. The SDK source code is freely available on [github](https://github.com/STMicroelectronics-CentralLabs/)

## Download the source

Since the project uses git submodules, <code>--recursive</code> option must be used to clone the repository:

```Shell
git clone --recursive https://github.com/STMicroelectronics-CentralLabs/STSensNet_iOS
```

or run
```Shell
git clone https://github.com/STMicroelectronics-CentralLabs/STSensNet_iOS
git submodule update --init --recursive
```

## License

Copyright (c) 2017  STMicroelectronics – All rights reserved
The STMicroelectronics corporate logo is a trademark of STMicroelectronics

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions
and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright notice, this list of
conditions and the following disclaimer in the documentation and/or other materials provided
with the distribution.

- Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
STMicroelectronics company nor the names of its contributors may be used to endorse or
promote products derived from this software without specific prior written permission.

- All of the icons, pictures, logos and other images that are provided with the source code
in a directory whose title begins with st_images may only be used for internal purposes and
shall not be redistributed to any third party or modified in any way.

- Any redistributions in binary form shall not include the capability to display any of the
icons, pictures, logos and other images that are provided with the source code in a directory
whose title begins with st_images.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.

