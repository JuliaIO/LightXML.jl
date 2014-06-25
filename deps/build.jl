@windows_only begin
using BinDeps

@BinDeps.setup

libxml2 = library_dependency("libxml2-2")
using WinRPM
provides(WinRPM.RPM, "libxml2", libxml2, os = :Windows)

@BinDeps.install
end
