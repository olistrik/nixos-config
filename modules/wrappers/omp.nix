{
  wrappers.config.omp =
    {
      my,
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ my.modules.wrappers.programs.omp ];
      config = { };
    };

  wrappers.programs.omp =
    {
      config,
      pkgs,
      lib,
      wlib,
      my,
      ...
    }:
    let
      ompPython = pkgs.python3.withPackages (ps: with ps; [ pip ipykernel ipython ]);
    in
    {
      imports = [ wlib.modules.default ];

      config = {
        package = my.pkgs.omp;
        binName = "omp";

        env = {
          PI_PY = "${ompPython}/bin/python3";
          PUPPETEER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
        };
      };
    };
}
