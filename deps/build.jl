@static VERSION < v"0.7.0-DEV" || (const is_windows = Sys.iswindows)
@static if is_windows()
    using WinRPM
    WinRPM.install("libxml2-2", yes=true)
end
