{ config, lib, pkgs, ... }:

let
  cfg =  config.env;
  
in {

  options = {
    env.role.development = lib.mkEnableOption "development role";
  };

  config = lib.mkIf cfg.role.development {

    # nixpkgs.config = {
    #   packageOverrides = pkgs: rec {
    #     jetbrains = pkgs.jetbrains.override {
    #       jdk = pkgs.jdk11;  
    #     };
    #   };
    # };

    env.role.virtualisation = lib.mkForce true;

    programs.adb.enable = true;
    
    users.users.${cfg.user.name}.extraGroups = ["adbusers"];

    services.globalprotect = {
      enable = true;
      # if you need a Host Integrity Protection report
      csdWrapper = "${pkgs.openconnect}/libexec/openconnect/hipreport.sh";
    };

    env.programs.vscode.enable = true;
    env.programs.gradle.enable = true;

    env.programs.docker.enable = true;


    environment.systemPackages = with pkgs; [
      git-lfs

      pkg-config           # build dependency çözümü için
      llvmPackages.llvm    # bazı crates için gerekli (örn. bindgen)
      binutils-unwrapped


      clang-tools
      gcc
      glibc.static
      clang
      gdb
      cmake                # bazı Rust crates C/C++ backend kullanıyorsa
      ninja                # build hızlandırmak için      
      gnumake

      rust-analyzer        # VSCode / LSP için language server
      rustfmt              # kod formatlama
      rustc                # Rust compiler
      cargo                # Rust package manager & build tool
      cargo-edit           # cargo add / remove / upgrade
      cargo-watch          # dosya değişince otomatik rebuild / test
      cargo-audit          # güvenlik kontrolü

      clippy               # linting
      rust-bindgen



      python3
      poetry

      # go
      # gopls
      # gopkgs
      # go-outline
      # go-tools

      nodejs_22
      typescript
      pnpm
      esbuild
      prisma
      prisma-engines
      
      nixd
      nixfmt-rfc-style


      jdk17
      maven
      jetbrains.idea-oss

      android-studio
      android-tools

      postman
      meld


      xorg.libXrender
      xorg.libX11
      xorg.libXext
      xorg.libXtst
      xorg.libXi

      dbeaver-bin
      aider-chat-full

      delve

      wireshark
      twinkle
    ];

    programs.npm = {
      enable = true;
      npmrc = ''
        prefix = ''${XDG_DATA_HOME}/npm
        cache = ''${XDG_CACHE_HOME}/npm
        tmp = ''${XDG_RUNTIME_DIR}/npm
      '';
    };

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    environment.variables = {
      JAVA_HOME = "${pkgs.jdk17.home}";
      JDK_HOME = "${pkgs.jdk17.home}";
    };
  };
}
