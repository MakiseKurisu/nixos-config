{ stdenvNoCC
, lib
, bash
, coreutils
}:

stdenvNoCC.mkDerivation rec {
  name = "android-system-bin-wrapper";
  installPhase = ''
    mkdir -p "$out/bin"

    cat <<EOF >"$out/bin/android-system-bin-wrapper"
    #!${lib.getBin bash}/bin/bash

    /android/system/bin/linker64 "/android/system/bin/\$(${lib.getBin coreutils}/bin/basename "\$0")" "\$@"
    EOF
    chmod +x "$out/bin/android-system-bin-wrapper"

    mapfile -t android_bin <"${./android-system-bin.list}"
    for i in "''${android_bin[@]}"; do
      ln -s android-system-bin-wrapper "$out/bin/$i"
    done
  '';
  dontUnpack = true;

  buildInputs = [
    bash
    coreutils
  ];

  meta = {
    maintainers = with lib.maintainers; [ MakiseKurisu ];
    description = "Wrappers for /android/system/bin";
    platforms = lib.platforms.unix;
  };
}
