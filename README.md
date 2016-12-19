Install and configure

1., Download and install ControlPlane app (https://www.controlplaneapp.com)
2., Start ControlPlane app
    Upgrade it and restart (unfortunately an older version link on the site)
    It will ask about the multiple active context, aprove it!
3., Open Terminal app
    execute the install.sh script as root (sudo ~/extracted/stuff/install.sh)
    execute again the install.sh if any data changed, like you changed your password
4., Configure ControlPlane app
    Click to the airplane icon in the menu bar
    Activate "Sticky forced contexts"
    Open preferences
        General tab
            [X] Enable automatic switching
            [X] Start ControlPlane at login
            [X] Use Notifications
            [X] Check for updates on startup
            [ ] Hide from status bar (DO NOT TURN ON!)
            Show [Icon [V] in status bar
            [ ] Use switch moothing
            [ ] Restore previous context when ControlPlane starts
            [ ] Use default context
            Confidence required to switch: 75%
        Contexts tab
            add a new context with Work name (do not add to as a child)
        Evidence Sources tab
            turn on the followings and off the others
            - Assigned IP Address
            - Nearby WiFi Network
        Rules tab - Add the following rules if you want to auto activate VPN on a WiFI,
                    otherwise you do not need to set up rules
            add a 'Nearby WiFi Network' rule with the following data
                SSID: WeWork
                Context: Work
                Confidence: 50%
            add a 'Assigned IP Address rule with the following data
                IPv4 Address: 10.46.0.0
                Netmask: 255.255.0.0
                Context: Work
                Confidence: 50%
        Actions tab
            add a new 'System Actions -> Run Shell Script' with the following data
                Parameter: /the/folder/to/extracted/start.sh
                Description: Docler Connect
                Context: Work [On arrival]
                Delay: None
                [X] Enabled
            add a new 'System Actions -> Run Shell Script' with the following data
                Parameter: /the/folder/to/extracted/stop.sh
                Description: Docler Disconnect
                Context: Work [On departure]
                Delay: None
                [X] Enabled
