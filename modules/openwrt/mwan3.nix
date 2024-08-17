{
  packages = [
    "luci-app-mwan3"
  ];

  uci = {
    settings = {
      mwan3 = {
        globals.globals = {
          mmx_mask = "0x3F00";
        };
      };
    };
  };
}
