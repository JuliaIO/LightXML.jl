using BinDeps

@BinDeps.setup

libxml = library_dependency("libxml2", aliases=["libxml2-2"])

# Windows
downloadsdir = BinDeps.downloadsdir(libxml)
libdir = BinDeps.libdir(libxml)
downloadname = WORD_SIZE == 32 ? "libxml2-2.9.1-win32-x86.7z : "libxml2-2.9.1-win32-x86_64.7z"

# BinDeps complains about the .7z file on other platforms...
@windows_only provides(BuildProcess,
    (@build_steps begin
        FileDownloader("ftp://ftp.zlatkovic.com/libxml/64bit/$downloadname", joinpath(downloadsdir, downloadname))
	CreateDirectory(BinDeps.srcdir(libxml), true)
	FileUnpacker(joinpath(downloadsdir, downloadname), BinDeps.srcdir(libxml), joinpath(BinDeps.srcdir(libxml),"bin"))
	CreateDirectory(libdir, true)
	@build_steps begin
	    ChangeDirectory(joinpath(BinDeps.srcdir(libxml),"bin"))
	    FileRule(joinpath(libdir,"libxml2-2.dll"), @build_steps begin
	        `cp *.dll $(libdir)`
	    end)
	end
     end), libxml, os = :Windows)

@windows_only push!(BinDeps.defaults, BuildProcess)

@BinDeps.install [:libxml => :libxml]

@windows_only pop!(BinDeps.defaults)
