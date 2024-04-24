{ stdenvNoCC
, lib
, bash
, coreutils
}:

stdenvNoCC.mkDerivation rec {
  name = "android-system-bin-wrapper";
  installPhase = ''
    mkdir -p "$out/bin"

    cat <<EOF >"$out/bin/${name}"
    #!${lib.getBin bash}/bin/bash

    __help() {
      cat <<HELP >&2
    Usage: \$0 COMMAND [COMMAND OPTIONS]
    HELP
    }

    CMD_NAME="\$(${lib.getBin coreutils}/bin/basename "\$0")"

    if [[ \$CMD_NAME == "${name}" ]]; then
      case \$# in 
      0)
        __help
        exit 1
        ;;
      *)
        CMD_NAME="\$1"
        shift
        ;;
      esac
    fi

    /android/system/bin/linker64 "/android/system/bin/\$CMD_NAME" "\$@"
    EOF
    chmod +x "$out/bin/${name}"

    mapfile -t android_bin <"${./android-system-bin.list}"
    for i in "''${android_bin[@]}"; do
      ln -s "${name}" "$out/bin/$i"
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
