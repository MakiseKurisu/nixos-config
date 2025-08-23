{ stdenvNoCC
, lib
, bash
, coreutils
, android-system-bin-list
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

    __linker() {
      local CMD_PATH="\$1"
      shift
      LD_LIBRARY_PATH=/apex/com.android.runtime/lib/ /android/system/bin/linker "\$CMD_PATH" "\$@"
    }

    __linker64() {
      local CMD_PATH="\$1"
      shift
      LD_LIBRARY_PATH=/apex/com.android.runtime/lib64/ /android/system/bin/linker64 "\$CMD_PATH" "\$@"
    }

    __sh() {
      __linker64 /android/system/bin/sh "\$@"
    }

    CMD_NAME="\$("${lib.getBin coreutils}/bin/basename" "\$0")"

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

    CMD_PATH="/android/system/bin/\$CMD_NAME"
    if [[ ! -e "\$CMD_PATH" ]]; then
      echo "Cannot execute '\$CMD_PATH' which does not exist." >&2
      exit 1
    fi

    REAL_PATH="\$("${lib.getBin coreutils}/bin/realpath" "\$CMD_PATH")"
    case "\$(__linker64 /android/system/bin/file "\$REAL_PATH")" in
    *stripped*)
      "\$CMD_PATH" "\$@"
      ;;
    */system/bin/linker64*)
      __linker64 "\$CMD_PATH" "\$@"
      ;;
    */system/bin/linker*)
      __linker "\$CMD_PATH" "\$@"
      ;;
    */system/bin/sh*)
      __sh "\$CMD_PATH" "\$@"
      ;;
    *"ASCII text"*)
      echo "Cannot execute '\$CMD_PATH' which is a plain text file." >&2
      exit 1
      ;;
    *directory*)
      echo "Cannot execute '\$CMD_PATH' which is a directory." >&2
      exit 1
      ;;
    *)
      echo "Cannot execute '\$CMD_PATH' which is an unknown type of file." >&2
      exit 1
      ;;
    esac
    EOF
    chmod +x "$out/bin/${name}"

    mapfile -t android_bin <"${android-system-bin-list}"
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
