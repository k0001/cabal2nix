{-# LANGUAGE RecordWildCards #-}

module Cabal2Nix.PostProcess ( postProcess ) where

import Distribution.NixOS.Derivation.Cabal
import Data.List

postProcess :: Derivation -> Derivation
postProcess deriv@(MkDerivation {..})
  | pname == "alex"             = deriv { buildTools = "perl":buildTools }
  | pname == "cairo"            = deriv { extraLibs = "pkgconfig":"libc":"cairo":"zlib":extraLibs }
  | pname == "editline"         = deriv { extraLibs = "libedit":extraLibs }
  | pname == "epic"             = deriv { extraLibs = "gmp":"boehmgc":extraLibs, buildTools = "happy":buildTools }
  | pname == "ghc-mod"          = deriv { postInstall = ghcModPostInstall, buildTools = "emacs":buildTools }
  | pname == "glade"            = deriv { extraLibs = "pkgconfig":"libc":extraLibs, pkgConfDeps = "gtkC":delete "gtk" pkgConfDeps }
  | pname == "glib"             = deriv { extraLibs = "pkgconfig":"libc":extraLibs }
  | pname == "GLUT"             = deriv { extraLibs = "glut":"libSM":"libICE":"libXmu":"libXi":"mesa":extraLibs }
  | pname == "gtk"              = deriv { extraLibs = "pkgconfig":"libc":extraLibs, buildDepends = delete "gio" buildDepends }
  | pname == "gtksourceview2"   = deriv { extraLibs = "pkgconfig":"libc":extraLibs }
  | pname == "haddock"          = deriv { buildTools = "alex":"happy":buildTools }
  | pname == "happy"            = deriv { buildTools = "perl":buildTools }
  | pname == "haskell-src"      = deriv { buildTools = "happy":buildTools }
  | pname == "haskell-src-meta" = deriv { buildDepends = "uniplate":buildDepends }
  | pname == "hmatrix"          = deriv { extraLibs = "gsl":"liblapack":"blas":extraLibs }
  | pname == "idris"            = deriv { buildTools = "happy":buildTools }
  | pname == "leksah-server"    = deriv { buildDepends = "process-leksah":buildDepends }
  | pname == "multiarg"         = deriv { buildDepends = "utf8String":buildDepends }
  | pname == "OpenAL"           = deriv { extraLibs = "openal":extraLibs }
  | pname == "OpenGL"           = deriv { extraLibs = "mesa":"libX11":extraLibs }
  | pname == "pango"            = deriv { extraLibs = "pkgconfig":"libc":extraLibs }
  | pname == "persistent"       = deriv { extraLibs = "sqlite3":extraLibs }
  | pname == "repa-algorithms"  = deriv { extraLibs = "llvm":extraLibs }
  | pname == "repa-examples"    = deriv { extraLibs = "llvm":extraLibs }
  | pname == "SDL-image"        = deriv { extraLibs = "SDL_image":extraLibs }
  | pname == "SDL-mixer"        = deriv { extraLibs = "SDL_mixer":extraLibs }
  | pname == "SDL-ttf"          = deriv { extraLibs = "SDL_ttf":extraLibs }
  | pname == "svgcairo"         = deriv { extraLibs = "libc":extraLibs }
  | pname == "terminfo"         = deriv { extraLibs = "ncurses":extraLibs }
  | pname == "threadscope"      = deriv { configureFlags = "--ghc-options=-rtsopts":configureFlags }
  | pname == "vacuum"           = deriv { extraLibs = "ghcPaths":extraLibs }
  | pname == "wxcore"           = deriv { extraLibs = "wxGTK":"mesa":"libX11":extraLibs }
  | pname == "wxc"              = deriv { extraLibs = "wxGTK":"mesa":"libX11":extraLibs, postInstall = wxcPostInstall }
  | pname == "X11" && version >= (Version [1,6] [])
                                = deriv { extraLibs = "libXinerama":"libXext":"libXrender":extraLibs }
  | pname == "X11"              = deriv { extraLibs = "libXinerama":"libXext":extraLibs }
  | pname == "X11-xft"          = deriv { extraLibs = "pkgconfig":"freetype":"fontconfig":extraLibs
                                        , configureFlags = "--extra-include-dirs=${freetype}/include/freetype2":configureFlags
                                        }
  | otherwise                   = deriv

ghcModPostInstall :: String
ghcModPostInstall = unlines
                    [ "postInstall = ''"
                    , "    cd $out/share/$pname-$version"
                    , "    make"
                    , "    rm Makefile"
                    , "    cd .."
                    , "    ensureDir \"$out/share/emacs\""
                    , "    mv $pname-$version emacs/site-lisp"
                    , "  '';"
                    ]

wxcPostInstall :: String
wxcPostInstall = unlines
                 [ "postInstall = ''"
                 , "    cp -v dist/build/libwxc.so.${self.version} $out/lib/libwxc.so"
                 , "  '';"
                 ]
