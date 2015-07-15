using BinDeps, Compat

@BinDeps.setup

libxml2 = library_dependency("libxml2", aliases="libxml2-2")
@windows_only begin
    using WinRPM
    provides(WinRPM.RPM, "libxml2-2", libxml2, os = :Windows)
end

@BinDeps.install @compat(Dict(:libxml2 => :libxml2))
