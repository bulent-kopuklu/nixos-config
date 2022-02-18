{ pkgs, theme, wifiSupport }:

let
  rofi-theme = import ./rofi-themes/polybar-network-menu.nix { inherit pkgs theme; };

  app = let
    hasWifiDevice = toString wifiSupport;
    rofi = "${pkgs.rofi}/bin/rofi -dmenu -theme ${rofi-theme}/share/polybar-network-menu.rasi";

    ip = "${pkgs.iproute2}/bin/ip";
    awk = "${pkgs.gawk}/bin/awk";
    nmcli = "${pkgs.networkmanager}/bin/nmcli";
    grep = "${pkgs.gnugrep}/bin/grep";
    echo = "${pkgs.coreutils}/bin/echo";
    wc = "${pkgs.coreutils}/bin/wc";
    wget = "${pkgs.wget}/bin/wget";
    nmtui = "${pkgs.networkmanager}/bin/nmtui";
    bmon = "${pkgs.bmon}/bin/bmon";
    
    opt = {
      airplaneMode="${theme.icons.airplane}";
      launchNmtui="${theme.icons.cog}";
      launchBmon="${theme.icons.eye}";
    };
  in
  pkgs.writeShellScriptBin "polybar-network-menu" ''
    IFS=$'\n'
    function collect_network_devices() {

      local devices=$(${nmcli} -t -f device,type,state,connection dev status | ${grep} -v -E 'unmanaged|bridge')
      local connections=$(${nmcli} -t -f name,type,device connection show | ${grep} -v 'bridge')

      networks=""
      for d in $devices; do
        local dd=$(${echo} $d | ${awk} -F':' '{print $1}')
        local dt=$(${echo} $d | ${awk} -F':' '{print $2}')
        local ds=$(${echo} $d | ${awk} -F':' '{print $3}')
        local dn=$(${echo} $d | ${awk} -F':' '{print $4}')

        if [ -z $dn ] && [ $dt != "wifi" ]; then
          for c in $connections; do
            local cn=$(${echo} $c | ${awk} -F':' '{print $1}')
            local ct=$(${echo} $c | ${awk} -F':' '{print $2}')

            if [ $ct != "802-11-wireless" ]; then
              cd=$(${nmcli} connection show $cn | ${awk} '/connection.interface-name/ {print $2}')
              if [ $dd == $cd ]; then
                dn=$cn
                break
              fi
            fi
          done
        fi

        networks+="$dd:$dt:$ds:$dn$IFS"

      done
    }

    function find_default_network() {
      local default_network_ifs=$(${ip} route | ${awk} '/default/ {print $5}')  
      if [ -n "$default_network_ifs" ]; then
        for default_network_if in $default_network_ifs; do
          if [ -n "$networks" ] && [ "$(echo "$networks" | wc -l)" -gt 0  ]; then
            for n in $networks; do
              local ni=$(${echo} $n | ${awk} -F':' '{print $1}')
              if [ "$ni" == "$default_network_if" ]; then
                default_network=$n
                break;
              fi
            done
          fi
          break
        done
      else
        default_network=""
      fi
    }

    function prepare_default_network_icon() {
      if [ -n "$default_network" ]; then
        local t=$(${echo} $default_network | ${awk} -F':' '{print $2}')
        if [ "$t" == "wifi" ]; then
          default_network_icon=${theme.icons.wifi}
        elif  [ "$t" == "ethernet" ]; then
          default_network_icon=${theme.icons.ethernet}
        fi
      else
        default_network_icon=${theme.icons.network-offline}
      fi
    }

    function prepare_rofi_prompt() {
      if [ -z "$default_network_icon" ]; then
        prepare_default_network_icon
      fi

      if [ -n "$default_network" ]; then
        local n=$(${echo} $default_network | ${awk} -F':' '{print $4}')
        local d=$(${echo} $default_network | ${awk} -F':' '{print $1}')
        rofi_prompt="$default_network_icon $n $d"
      else
        rofi_prompt="$default_network_icon offline"
      fi
    }

    function prepare_rofi_message() {
      local d=$(${echo} $default_network | ${awk} -F':' '{print $1}')

      local lip=$(${ip} addr show dev $d | ${awk} '/inet / {print $2}')
      local gateway=$(${nmcli} device show $d | ${awk} '/IP4.GATEWAY/ {print $2}')
      local dns=$(${nmcli} device show $d | ${awk} '/IP4.DNS\[1\]/ {print $2}')
    #  local pip=$(dig +short myip.opendns.com @resolver1.opendns.com)
      local pip=$(${wget} -O - -q --timeout=3 https://checkip.amazonaws.com)

      rofi_message="""<b>local ip:</b> $lip
    <b>gateway:</b> $gateway
    <b>dns:</b> $dns
    <b>public ip:</b> $pip"""
    }

    # airplane ethernet |wifi|
    function prepare_rofi_options() {
      rofi_options="${opt.airplaneMode}\\n${theme.icons.ethernet}\\n"
      if [ "${hasWifiDevice}" == "1" ]; then
        rofi_options+="${theme.icons.wifi}\\n"
      fi
      rofi_options+="${opt.launchNmtui}\\n${opt.launchBmon}"
    }

    function add_rofi_active() {
      if [ -z $rofi_active ]; then
        rofi_active=$1
      else
        rofi_active+=",$1"
      fi
    }

    function add_rofi_urgent() {
      if [ -z $rofi_urgent ]; then
        rofi_urgent=$1
      else
        rofi_urgent+=",$1"
      fi
    }

    function prepare_rofi_active_urgent() {
      if [ "enabled" == $(${nmcli} networking) ]; then
        add_rofi_urgent 0
        for n in $networks; do
          local type=$(${echo} $n | ${awk} -F':' '{print $2}')
          if [ $type == "ethernet" ]; then
            local status=$(${echo} $n | ${awk} -F':' '{print $3}')
            if [ $status == "connected" ]; then
              add_rofi_active 1
            else
              add_rofi_urgent 1
            fi
          fi
        done
        
        if [ "${hasWifiDevice}" == "1" ]; then
          if [ "enabled" == $(${nmcli} radio wifi) ]; then
            add_rofi_active 2
          else
            add_rofi_urgent 2
          fi
        fi
      else
        add_rofi_active 0
      fi
    }

    function execute_rofi() {
      chosen=$(${echo} -e $rofi_options | ${rofi} -p "$rofi_prompt" -mesg "$rofi_message" -a "$rofi_active" -u "$rofi_urgent" -selected-row 3)
    }

    function apply_action() {
        case $chosen in
          ${opt.airplaneMode})
            if [ "disabled" == "$(${nmcli} networking)" ]; then
              ${nmcli} networking on
            else
              ${nmcli} networking off
            fi
            ;;
          ${theme.icons.ethernet})
            for n in $networks; do
              local type=$(${echo} $n | ${awk} -F':' '{print $2}')
              if [ "$type" == "ethernet" ]; then
                local status=$(${echo} $n | ${awk} -F':' '{print $3}')
                local name=$(${echo} $n | ${awk} -F':' '{print $4}')
                if [ "$status" == "connected" ]; then
                  ${nmcli} connection down "$name"
                elif [ "$status" == "disconnected" ]; then
                  ${nmcli} connection up "$name"
                fi
              fi
            done
            ;;
          ${theme.icons.wifi})
            if [ "disabled" == "$(${nmcli} radio wifi)" ]; then
              ${nmcli} radio wifi on
            else
              ${nmcli} radio wifi off
            fi
            ;;
          ${opt.launchNmtui})
            exec $TERMINAL -e ${nmtui}
            ;;
          ${opt.launchBmon})
            exec $TERMINAL -e ${bmon}
            ;;
        esac
      
    }

    collect_network_devices
    find_default_network
    prepare_default_network_icon

    prepare_rofi_options
    prepare_rofi_prompt
    prepare_rofi_message
    prepare_rofi_active_urgent

    execute_rofi

    apply_action
  '';
in 
pkgs.symlinkJoin {
  name = "polybar-network-menu";
  version = "1";
  paths = [ rofi-theme app ];
}
