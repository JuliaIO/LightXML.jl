using BinDeps

@BinDeps.setup

@windows_only begin
libxml2 = library_dependency("libxml2", aliases = ["libxml2-2"])
using WinRPM
provides(WinRPM.RPM, "libxml2", libxml2, os = :Windows)
end

@BinDeps.install
