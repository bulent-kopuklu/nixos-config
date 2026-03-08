# Gradle wrapper: Sets GRADLE_USER_HOME to .local/share/gradle
# Prevents ~/Android clutter from Gradle/Android Studio

final: prev:
let
  wrappedGradle = prev.symlinkJoin {
    name = "gradle";
    paths = [ prev.gradle ];
    buildInputs = [ prev.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/gradle" \
        --set-default GRADLE_USER_HOME "$HOME/.local/share/gradle"
    '';
  };
in {
  gradle = wrappedGradle;
}
