{
  uci = {
    settings = {
      wireless = {
        wifi-device = {
          radio0 = {
            type = "mac80211";
            channel = "auto";
            band = "2g";
            htmode = "HT20";
            country = "CN";
            cell_density = 0;
          };
          radio1 = {
            type = "mac80211";
            channel = "auto";
            band = "5g";
            htmode = "HE160";
            country = "CN";
            cell_density = 0;
          };
        };
        wifi-iface = {
          default_radio0 = {
            device = "radio0";
            network = "guest";
            mode = "ap";
            wds = 1;
            encryption = "psk2";
            ssid._secret = "guest_wifi_ssid";
            key._secret = "guest_wifi_password";
            isolate = 1;
          };
          default_radio1 = {
            device = "radio1";
            network = "lan";
            mode = "ap";
            wds = 1;
            encryption = "psk2";
            ssid._secret = "lan_wifi_ssid";
            key._secret = "lan_wifi_password";
          };
        };
      };
    };
  };
}
