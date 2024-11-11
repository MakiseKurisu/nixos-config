{ config, lib, pkgs, ... }:

{
  users.users.excalibur = {
    isNormalUser = true;
    description = "Excalibur";
    extraGroups = [
      "adbusers"
      "aria2"
      "audio"
      "cups"
      "dialout"
      "incus"
      "input"
      "lp"
      "networkmanager"
      "realtime"
      "render"
      "scanner"
      "video"
      "wheel"
      "wireshark"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpjg4DfyD4APGO4s+YX77d6kPFlpl88qgLHaxDp8Qd8tK3mA0Mfy5Ep94u+T/zKSX7zTnL5OsfE/8S5P2BuV3C7nD4XR3oTJNmdovRO2Yig0uGuKbH5bkkt4pRcA0n3qvT7P9pcrUd/l6FrkLyFAQnVLVUxJ7JdApEviQrnXXj8jZGUQ4267CPR44VPFGfQVa+J62SUFpj/KDFp4uV1Yl3rpTzmjCXA3CZF9vDqDjARN0Yjxb3gwYzMuAfK/FRdwH7OBOmwEHg/ZjEpBDL69lAfCeZmz6j0VHIerGQR3lsKxVf4SyItqhPId/AwaPjl1wisHqfsOxxohacD3mYo9eFrupHbpKP8k1VTwR2FizGIza/kE8caKRk9oAABmMj2Dteo6qAoKrEpLZPwxVZf11R3UZec2trL3TneKcaXm7WHVqwDTgQ7rhzZqa/kqsrs2yThHap/1lAnQcf+UK5o1kOjpGhF+LzAuiErsXuIwCjxmpSU1bgpy0OaR8yQ6liG1c= excalibur@aur"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJWII9m7aZOFxCyr1xs1maoU2zrzjBYzY1o1UUzIGH1F excalibur@cix"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNbARwJPNYn4MUPHvy7JRR7B+Yh2t50K7xUbMvdf58U1IPYOfDB818atx0MoJvvMro7H3NXateXMnFW6h111FkeTN4e6pLePIOCIyX20S9U6rq85T81ePTi9ied6SP6IEpyGEdWO73eiXbZAOj9VPnXOir3tvrKRNISz3mHp163NT7HMHRJjZ+9xCUhqPzw0VrKD3fTbrljdKk8Rfpd0wDvv2Nb6DA+nfvYME3w1ICU73Y4oP2x+Sx6epqr/FXk6vBsrKdyxPEALirCtct8LYYrt1KxTI2yfodr9kiOFgPIMwzuKPRixV2S15Eh5NwL5Hi6+RNQRXu82V8osSFUC0OypFplmTrY5yAHzDQB5DOYWlRG4KeKACd/tB2HMuW46qWIxngXYR2WSoAHFDdSuKj+fTsb21uQ+LvoQU6mnfUyYDokHuDPMi4iUlgFpcmyeNq1Dm7OD0LWLRbIdpJYgtd4aT9uT3XIQ8Ic8X/sZuNTv1jGLDhZMdV/awHtfDggtE= excalibur@vamrs"
    ];
  };
}
