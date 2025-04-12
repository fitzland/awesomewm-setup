It seems there's an issue with the communication between notify-send and your AwesomeWM setup. The "unexpected reply type" error usually occurs when there's a mismatch in how the notification is being processed.

Let's try a different approach to test your notifications:

1. Try using awesome-client directly:
```bash
echo 'naughty = require("naughty"); naughty.notify({title="Test", text="Testing notifications", icon="/usr/share/icons/Papirus/48x48/apps/firefox.svg"})' | awesome-client
```

2. If that works, there might be an issue with how notify-send is communicating with the notification system. 

Another possibility is to check if your system is using the correct DBus interface for notifications:

```bash
gdbus introspect --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications
```

This should show you details about the notification service currently running. If that command fails, it might indicate that the notification service isn't properly registered with DBus.

Would you like me to provide a more detailed troubleshooting guide for notification issues?
