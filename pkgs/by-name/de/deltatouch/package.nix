{ lib
, stdenv
, fetchFromGitea
, cmake
, intltool
, libdeltachat
, clickable
, qt5
, quirc
}:

stdenv.mkDerivation rec {
  pname = "deltatouch";
  version = "unstable";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "lk108";
    repo = "deltatouch";
    rev = "6e2805515b9e3a3bbdf4871eda2a0fe65500aa1d";
    hash = "sha256-jCoT4AdI8XOBhvtNsNdweLQb8XRD3YnDpnx4VRFHfN0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
    intltool
    clickable
    cmake
  ];

  patchPhase = ''
    mkdir -p $out/share
    mkdir -p $out/lib

    substituteInPlace CMakeLists.txt --replace "set(DATA_DIR /)" "set(DATA_DIR $out/share)"
    substituteInPlace plugins/DeltaHandler/CMakeLists.txt --replace '/lib/' '${placeholder "out"}/lib/'
    substituteInPlace plugins/DTWebEngineProfile/CMakeLists.txt --replace '/lib/' '${placeholder "out"}/lib/'
    echo "#include <array>" > tmp
    cat tmp plugins/DeltaHandler/deltahandler.cpp > tmp2
    mv tmp2 plugins/DeltaHandler/deltahandler.cpp
    mkdir -p build/plugins/DeltaHandler
    cp --no-preserve=mode ${libdeltachat}/lib/libdeltachat.so build/plugins/DeltaHandler/libdeltachat.so
    cp --no-preserve=mode ${quirc}/lib/libquirc.so.1.0 build/plugins/DeltaHandler/libquirc.so.1.2
  '';

  buildInputs = [
    qt5.qtbase
    qt5.qtwebengine
    qt5.qtquickcontrols2
#    (libdeltachat.overrideAttrs { patches = [ "${src}/libs/patches/dc_core_rust-CMakeLists.patch" ]; })
#    quirc
  ];

  meta = with lib; {
    description = "Messaging app for Ubuntu Touch, powered by deltachat-core. \r\n<a rel=\"me\" href=\"https://social.tchncs.de/@deltatouch\">Fediverse</a>: @deltatouch@social.tchncs.de";
    homepage = "https://codeberg.org/lk108/deltatouch";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "deltatouch";
    platforms = platforms.all;
  };
}
