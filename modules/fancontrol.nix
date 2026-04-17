{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  # Enable lm_sensors hardware monitoring
  hardware.sensor.iio.enable = true;
}
