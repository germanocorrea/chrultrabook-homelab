{
  pkgs,
  ...
}:

{
  # systemd.timers."connection-tester" = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnBootSec = "5m";
  #     OnUnitActiveSec = "5m";
  #     Unit = "connection-tester.service";
  #   };
  # };

  # systemd.services."connection-tester" = {
  #   script = "";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "root";
  #   };
  # };

  systemd.timers."power-tester" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "power-tester.service";
    };
  };

  systemd.services."power-tester" = {
    script = ''
      PERSISTED_FILE="$HOME/.power-tester-state"
      CURRENT_STATE=$(cat /sys/class/power-supply/AC/online)
      if [[ -f $PERSISTED_FILE ]]; then
          PERSISTED_STATE=$(cat $PERSISTED_FILE)
      else
          PERSISTED_STATE=-1
      fi

      if [[ $CURRENT_STATE -eq 0 ]]; then
          MESSAGE="disconnected"
      else
          MESSAGE="connected"
      fi

      if [[ $PERSISTED_STATE -ne $CURRENT_STATE ]]; then
          echo "Power AC state changed: $MESSAGE" | nc -U /tmp/brokerbot/brokerbot.sock
          echo $CURRENT_STATE > $PERSISTED_FILE
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers."storage-tester" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "storage-tester.service";
    };
  };

  systemd.services."storage-tester" = {
    script = ''
      PERSISTED_FILE="$HOME/.storage-tester-state"
      CURRENT_STATE_STRING_OUTPUT=$(df -h --output='pcent,target' | grep Storage | column --table --table-columns 'percent,target' --table-hide 'target' -d)
      REMOVEDCHAR="%"
      CURRENT_STATE_STRING="${"\${CURRENT_STATE_STRING_OUTPUT//$REMOVEDCHAR/}"}"
      CURRENT_STATE=$((CURRENT_STATE_STRING))
      THRESHOLD=95
      if [[ -f $PERSISTED_FILE ]]; then
          PERSISTED_STATE=$(cat $PERSISTED_FILE)
      else
          PERSISTED_STATE=-1
      fi
      if [[ $CURRENT_STATE -gt $THRESHOLD ]] && [[ $CURRENT_STATE -gt $PERSISTED_STATE ]]; then
          echo "Storage space warning: $CURRENT_STATE%" | nc -U /tmp/brokerbot/brokerbot.sock
          echo $CURRENT_STATE > $PERSISTED_FILE
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
