# thunderbird-installer
 Install any version of thunderbird from Mozilla.org

 ## Installation

 ```bash
 curl -sSL https://tmiland.github.io/thunderbird-installer/thunderbird_installer.sh \
      -o thunderbird_installer.sh && \
      chmod +x thunderbird_installer.sh && \
      ./thunderbird_installer.sh -h
 ```

 ## Prerequisites

  - curl (will be installed)
  - packages that will be installed:
 ```bash
menu debianutils fontconfig libotr5 psmisc x11-utils kdialog zenity libasound2 libatk1.0-0 libc6 libcairo-gobject2 libcairo2 libdbus-1-3 libevent-2.1-7 libffi8 libfontconfig1 libfreetype6 libgcc-s1 libgdk-pixbuf2.0-0 libgdk-pixbuf-2.0-0 libglib2.0-0 libgtk-3-0 libpango-1.0-0 libstdc++6 libvpx7 libx11-6 libx11-xcb1 libxcb-shm0 libxcb1 libxext6 libxrandr2 zlib1g
 ```

  ## Usage:
  
 ```bash
 Usage: thunderbird_installer.sh [options]

   --help                 |-h   display this help and exit
   --latest               |-l   latest (141.0)
   --esr                  |-e   esr (140.1.0esr)
   --beta                 |-b   beta (142.0b2)
   --release              |-rl  select custom release to install*
   --backup-profile       |-bp  backup thunderbird profile
   --uninstall            |-u   uninstall thunderbird

   install from mozilla: [-t|-e|-b]
   uninstall:            [-t|-e|-b] -u
   * custom release for mozilla [-rl <release>]
 ```

 ## Donations
 <a href="https://coindrop.to/tmiland" target="_blank"><img src="https://coindrop.to/embed-button.png" style="border-radius: 10px; height: 57px !important;width: 229px !important;" alt="Coindrop.to me"></img></a>

 #### Disclaimer 

 *** ***Use at own risk*** ***

 ### License

 [![MIT License Image](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/MIT_logo.svg/220px-MIT_logo.svg.png)](https://tmiland.github.io/thunderbird-installer/blob/main/LICENSE)

 [MIT License](https://tmiland.github.io/thunderbird-installer/blob/main/LICENSE)