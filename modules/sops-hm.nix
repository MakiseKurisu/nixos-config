{
  lib,
  inputs,
  options,
  ...
}:

{
  config = lib.optionalAttrs (options ? home-manager) {
    home-manager = {
      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
      ];
      users.excalibur =
        { ... }@inputs':
        {
          sops = {
            age.sshKeyPaths = [ "/home/excalibur/.ssh/id_ed25519" ];
            defaultSopsFile = "${inputs.secrets}/nixos.yaml";
            secrets = {
              minimax_auth_token = { };
              sub2api_openai = { };
              sub2api_anthropic = { };
              nvidia_token = { };
              poe_auth_token = { };
            };
            templates = {
              "opencode-auth.json" = {
                content = builtins.toJSON {
                  deepseek = {
                    type = "api";
                    key = inputs'.config.sops.placeholder.sub2api_anthropic;
                  };
                  kimi-for-coding = {
                    type = "api";
                    key = inputs'.config.sops.placeholder.sub2api_anthropic;
                  };
                  minimax-cn-coding-plan = {
                    type = "api";
                    key = inputs'.config.sops.placeholder.minimax_auth_token;
                  };
                  moonshotai-cn = {
                    type = "api";
                    key = inputs'.config.sops.placeholder.sub2api_anthropic;
                  };
                  nvidia = {
                    type = "api";
                    key = inputs'.config.sops.placeholder.nvidia_token;
                  };
                  openai = {
                    type = "api";
                    key = inputs'.config.sops.placeholder.sub2api_openai;
                  };
                  poe = {
                    type = "api";
                    key = inputs'.config.sops.placeholder.poe_auth_token;
                  };
                  xai = {
                    type = "api";
                    key = inputs'.config.sops.placeholder.sub2api_openai;
                  };
                  xiaomi-token-plan-cn = {
                    type = "api";
                    key = inputs'.config.sops.placeholder.sub2api_anthropic;
                  };
                };
              };
            };
          };
        };
    };
  };
}
