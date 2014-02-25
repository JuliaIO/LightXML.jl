using BinDeps

@BinDeps.setup

deps = [
        libiconv = library_dependency("libiconv-2", aliases = ["libiconv"])
        libxml2 = library_dependency("libxml2", aliases = ["libxml2-2"], depends = [libiconv])
        ]

location = "ftp://ftp.zlatkovic.com/libxml/64bit/"
suffix = WORD_SIZE == 32 ? "-win32-x64.7z" : "-win32-x86_64.7z"
downloadnames = ["iconv-1.14", "libxml2-2.9.1"]

for i=1:2
    downloadsdir = BinDeps.downloadsdir(deps[i])
    downloadname = "$(downloadnames[i])$suffix"
    srcdir = joinpath(BinDeps.depsdir(deps[i]), downloadnames[i])
    libdir = BinDeps.libdir(deps[i])
    @windows_only provides(BuildProcess,
        (@build_steps begin
        FileDownloader("$location$downloadname", joinpath(downloadsdir, downloadname))
        CreateDirectory(srcdir, true)
        FileUnpacker(joinpath(downloadsdir, downloadname), srcdir, "bin")
        CreateDirectory(libdir, true)
        @build_steps begin
            ChangeDirectory(joinpath(srcdir, "bin"))
            FileRule(joinpath(libdir, "$(deps[i].name).dll"), @build_steps begin
                `cp $(deps[i].name)*.dll $(libdir)/$(deps[i].name).dll`
            end)
        end
        end), deps[i], os = :Windows)
end

@windows_only push!(BinDeps.defaults, BuildProcess)

@BinDeps.install

@windows_only pop!(BinDeps.defaults)
