//@ pragma UseQApplication
import Quickshell
import "modules" as Modules

ShellRoot {
    id: root

    Modules.Overlay {
        id: overlay
    }

    Modules.SlimBar {
        overlay: overlay
    }

    Modules.NotificationPopup {
    }

}
