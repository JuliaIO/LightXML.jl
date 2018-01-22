using Compat

@static if Compat.Sys.iswindows()
    using WinRPM
    WinRPM.install("libxml2-2", yes=true)
end
