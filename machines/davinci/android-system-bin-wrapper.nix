{ stdenvNoCC
, lib
, bash
}:

stdenvNoCC.mkDerivation rec {
  name = "android-system-bin-wrapper";
  installPhase = ''
    mkdir -p "$out/bin"
    mapfile -t android_bin <"${./android-system-bin.list}"
    for i in "''${android_bin[@]}"; do
      cat <<EOF >"$out/bin/$i"
    #!${lib.getBin bash}/bin/bash

    /android/system/bin/linker64 "/android/system/bin/$i" "\$@"
    EOF
      chmod +x "$out/bin/$i"
    done
  '';
  dontUnpack = true;

  buildInputs = [
    bash
  ];

  meta = {
    maintainers = with lib.maintainers; [ MakiseKurisu ];
    description = "Wrappers for /android/system/bin";
    platforms = lib.platforms.unix;
  };
}
