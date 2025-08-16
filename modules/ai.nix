{ config, lib, pkgs, inputs, options, ... }:

{
  services = {
    comfyui = {
      enable = true;
      # models = builtins.attrValues pkgs.nixified-ai.models;
      customNodes = with pkgs.comfyuiPackages; [
        comfyui-gguf
        # comfyui-impact-pack
      ];
    };
    llama-cpp = {
      enable = true;
      model = "/home/excalibur/.cache/llama.cpp/ggml-org_gpt-oss-20b-GGUF_gpt-oss-20b-mxfp4.gguf";
    };
  };
}
