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

    __linker() {
      local CMD_NAME="\$1"
      shift
      LD_LIBRARY_PATH=/apex/com.android.runtime/lib/ /android/system/bin/linker "/android/system/bin/\$CMD_NAME" "\$@"
    }

    __linker64() {
      local CMD_NAME="\$1"
      shift
      LD_LIBRARY_PATH=/apex/com.android.runtime/lib64/ /android/system/bin/linker64 "/android/system/bin/\$CMD_NAME" "\$@"
    }

    __sh() {
      local CMD_NAME="\$1"
      shift
      __linker64 sh "\$@"
    }

    CMD_NAME="\$("${lib.getBin coreutils}/bin/basename" "\$0")"

    if [[ \$CMD_NAME == "${name}" ]] && (( \$# == 0 )); then
      __help
      exit 1
    elif [[ ! -e "/android/system/bin/\$1" ]]; then
      echo "Cannot execute '/android/system/bin/\$1' which does not exist." >&2
      exit 1
    fi

    REAL_PATH="\$("${lib.getBin coreutils}/bin/realpath" "/android/system/bin/\$1")"
    case "\$(__linker64 file "\$REAL_PATH")" in
    */system/bin/linker64*)
      __linker64 "\$@"
      ;;
    */system/bin/linker*)
      __linker "\$@"
      ;;
    */system/bin/sh*)
      __sh "\$@"
      ;;
    *"ASCII text"*)
      echo "Cannot execute '/android/system/bin/\$1' which is a plain text file." >&2
      exit 1
      ;;
    *directory*)
      echo "Cannot execute '/android/system/bin/\$1' which is a directory." >&2
      exit 1
      ;;
    *)
      echo "Cannot execute '/android/system/bin/\$1' which is an unknown type of file." >&2
      exit 1
      ;;
    esac
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
