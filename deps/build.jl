using BinDeps

@BinDeps.setup

libxml2 = library_dependency("libxml2", aliases=["libxml2-2"])

# Windows
downloadsdir = BinDeps.downloadsdir(libxml2)
libdir = BinDeps.libdir(libxml2)
downloadname = WORD_SIZE == 32 ? "libxml2-2.9.1-win32-x86.7z" : "libxml2-2.9.1-win32-x86_64.7z"

# BinDeps complains about the .7z file on other platforms...
@windows_only provides(BuildProcess,
    (@build_steps begin
        FileDownloader("ftp://ftp.zlatkovic.com/libxml/64bit/$downloadname", joinpath(downloadsdir, downloadname))
	CreateDirectory(BinDeps.srcdir(libxml2), true)
	FileUnpacker(joinpath(downloadsdir, downloadname), BinDeps.srcdir(libxml2), joinpath(BinDeps.srcdir(libxml2),"bin"))
	CreateDirectory(libdir, true)
	@build_steps begin
	    ChangeDirectory(joinpath(BinDeps.srcdir(libxml2),"bin"))
	    FileRule(joinpath(libdir,"libxml2.dll"), @build_steps begin
	        `cp libxml2-2.dll $(libdir)/libxml2.dll`
	    end)
	end
     end), libxml2, os = :Windows)

@windows_only push!(BinDeps.defaults, BuildProcess)

@windows_only pop!(BinDeps.defaults)
