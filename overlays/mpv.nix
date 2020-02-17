self: super:

{
  mpv = super.mpv.override { vdpauSupport = false; };
}
