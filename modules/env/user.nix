{ config, lib, pkgs, ... }:

with builtins;
with lib;

let
  cfg = config.env;

  user-files-creator = pkgs.writeShellScriptBin "user-files-creator" ''
    for file in /etc/user-files-creator.d/*; do
      [ -f "$file" ] && [ -x "$file" ] && "$file"
    done
  '';

  mkUserFile = {user, filename, source}: let
    userProfile = "${config.users.users."${user}".home}";
    staticHome = "${userProfile}/.local/share/nixstatic";
  in ''
    ln -sf "${source}" "${staticHome}/${filename}"
  '';

  mkUserFileFromText = {user, filename, text}: let
    textfile = toFile filename text;
  in mkUserFile { inherit user filename; source = textfile; };

  mkCleanUp = {user, filename, homePath }: let
    userProfile = "${config.users.users."${user}".home}";
    staticHome = "${userProfile}/.local/share/nixstatic";
    updatedPath = "${userProfile}/${homePath}";
  in ''
    echo "rm -rf ${updatedPath}" >> ${staticHome}/cleanup.sh
    echo "rm -f ${staticHome}/${filename}" >> ${staticHome}/cleanup.sh
  '';

  mkLinker = {user, filename, homePath, group }: let
    userProfile = "${config.users.users."${user}".home}";
    staticHome = "${userProfile}/.local/share/nixstatic";
    targetPath = "${userProfile}/${homePath}";
    targetFolder = dirOf targetPath;
  in ''
    echo "Setting up user file ${targetPath} -> ${staticHome}/${filename}"

    mkdir -p "${targetFolder}"

    ln -sf "${staticHome}/${filename}" "${targetPath}"
    chown -h ${user}:${group} "${targetPath}"

    chown -c ${user}:${group} "${userProfile}"
  '';

  buildFileScript = {username, fileSet}: concatStringsSep "\n" 
    (map (name: (if (hasAttr "source" fileSet."${name}")
    then mkUserFile {user = username; filename = name; source = fileSet."${name}".source;}
    else mkUserFileFromText { user = username; filename = name; text = fileSet."${name}".text;}
    )) (attrNames fileSet));

  buildCleanUp = {username, fileSet}: concatStringsSep "\n"
    (map (name: mkCleanUp { user = username; homePath = fileSet."${name}".path; filename = name;}) (attrNames fileSet));

  buildLinker = {username, fileSet, group}: concatStringsSep "\n"
    (map (name: mkLinker { user = username; homePath = fileSet."${name}".path; filename = name; inherit group; }) (attrNames fileSet));

  mkBuildScript = {username, fileSet, group ? "users"}: let 
      staticPath = "${config.users.users."${username}".home}/.local/share/nixstatic";
    in ''
        echo "Setting up user files for ${username}"
        if [ -f "${staticPath}/cleanup.sh" ]; then
          echo "Cleaning user files for ${username}"
          ${staticPath}/cleanup.sh
          rm ${staticPath}/cleanup.sh
        fi

        mkdir -p ${staticPath}
        ${buildFileScript { inherit username fileSet; }}
        ${buildCleanUp { inherit username fileSet; }}
        if [ -f "${staticPath}/cleanup.sh" ]; then
          chmod +x ${staticPath}/cleanup.sh
        fi
        echo "Linking user files for ${username}"
        ${buildLinker { inherit username fileSet group; }}
    '';

in {
  options.env.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "bulentk";
      description = "The username of the primary user on the system";
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra groups to add to primary user";
    };

    files = lib.mkOption {
      type = types.attrs;
      default = {};
      description = "Files to add to all user profiles";
    };
  };

  config = {
    users.users."${cfg.user.name}" = {
      name = cfg.user.name;
      isSystemUser = false;
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = cfg.user.extraGroups;
      uid = 1000;
      createHome = true;
      home = "/home/${cfg.user.name}";
    };

    environment.etc."user-files-creator.d/${cfg.user.name}" = {
      text = mkBuildScript {username = cfg.user.name; fileSet = cfg.user.files; };
      mode = "0555";
    };

    systemd.services.user-files-creator = {
      enable = true;
      description = "User files creator services";
      wantedBy = [ "multi-user.target" ];

      unitConfig = {
        ConditionPathExists = "/home";
        Wants = [ "home.mount" ];
        After = [ "home.mount" ];
      };

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${user-files-creator}/bin/user-files-creator";
      };
    };
 
    nix.settings.trusted-users = [ "root" cfg.user.name ];

  };
}