{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jack2
    cadence
  ];

  # <driver name="alsa">
  #  <option name="device">hw:0</option>
  #  <option name="capture">hw:PCH,0</option>
  #  <option name="playback">hw:PCH,0</option>
  #  <option name="rate">48000</option>
  #  <option name="period">2048</option>
  #  <option name="nperiods">2</option>
  #  <option name="hwmeter">false</option>
  #  <option name="duplex">true</option>
  #  <option name="softmode">false</option>
  #  <option name="monitor">false</option>
  #  <option name="dither">n</option>
  #  <option name="inchannels">0</option>
  #  <option name="outchannels">2</option>
  #  <option name="shorts">false</option>
  # </driver>
}
