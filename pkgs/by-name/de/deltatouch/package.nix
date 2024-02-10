{ lib
, stdenv
, fetchFromGitea
, cmake
, intltool
, libdeltachat
, clickable
, qt5
, quirc
, lomiri
}:

stdenv.mkDerivation rec {
  pname = "deltatouch";
  version = "unstable";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "lk108";
    repo = "deltatouch";
    rev = "7b5e27044f64c5a92ca0493251d78d6663eba3f9";
    hash = "sha256-Jrr/TkfBp/vvGhrbVP+ZEUyNg3hiWRAQHD79HddpY0U=";
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
    mkdir -p build/plugins/DeltaHandler
    cp --no-preserve=mode ${libdeltachat}/lib/libdeltachat.so build/plugins/DeltaHandler/libdeltachat.so
    cp --no-preserve=mode ${quirc}/lib/libquirc.so.1.0 build/plugins/DeltaHandler/libquirc.so.1.2
  '';

  postInstall = ''
    mkdir -p $out/bin
    mv $out/deltatouch $out/bin
    cp --no-preserve=mode ${libdeltachat}/lib/libdeltachat.so $out/lib/libdeltachat.so
    cp --no-preserve=mode ${quirc}/lib/libquirc.so.1.0 $out/lib/libquirc.so.1.2
  '';

  qtWrapperArgs = [
    ''--prefix QML2_IMPORT_PATH : ${placeholder "out"}/lib''
    ''--set CLICKABLE_DESKTOP_MODE y'' # Hack to make sending/receiving messages work, we don't use clickable
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtwebengine
    qt5.qtquickcontrols2
    lomiri.lomiri-ui-toolkit
    lomiri.lomiri-ui-extras
    lomiri.lomiri-api
    lomiri.lomiri-indicator-network # Lomiri.Connectivity module
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
