# This file has been generated by node2nix 1.10.0. Do not edit!

{nodeEnv, fetchurl, fetchgit, nix-gitignore, stdenv, lib, globalBuildInputs ? []}:

let
  sources = {
    "@angular/language-service-13.1.0" = {
      name = "_at_angular_slash_language-service";
      packageName = "@angular/language-service";
      version = "13.1.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/@angular/language-service/-/language-service-13.1.0.tgz";
        sha512 = "tpK/0CljInRJNP/nizQ8Bj0yFsLLmbcqAJ5yUp4uDM9nVpgmHxzJIIpR/Sk+8KKMlED5eGRXjZKPY4zhlJTmqw==";
      };
    };
    "vscode-jsonrpc-6.0.0" = {
      name = "vscode-jsonrpc";
      packageName = "vscode-jsonrpc";
      version = "6.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-jsonrpc/-/vscode-jsonrpc-6.0.0.tgz";
        sha512 = "wnJA4BnEjOSyFMvjZdpiOwhSq9uDoK8e/kpRJDTaMYzwlkrhG1fwDIZI94CLsLzlCK5cIbMMtFlJlfR57Lavmg==";
      };
    };
    "vscode-languageserver-7.0.0" = {
      name = "vscode-languageserver";
      packageName = "vscode-languageserver";
      version = "7.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver/-/vscode-languageserver-7.0.0.tgz";
        sha512 = "60HTx5ID+fLRcgdHfmz0LDZAXYEV68fzwG0JWwEPBode9NuMYTIxuYXPg4ngO8i8+Ou0lM7y6GzaYWbiDL0drw==";
      };
    };
    "vscode-languageserver-protocol-3.16.0" = {
      name = "vscode-languageserver-protocol";
      packageName = "vscode-languageserver-protocol";
      version = "3.16.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-protocol/-/vscode-languageserver-protocol-3.16.0.tgz";
        sha512 = "sdeUoAawceQdgIfTI+sdcwkiK2KU+2cbEYA0agzM2uqaUy2UpnnGHtWTHVEtS0ES4zHU0eMFRGN+oQgDxlD66A==";
      };
    };
    "vscode-languageserver-types-3.16.0" = {
      name = "vscode-languageserver-types";
      packageName = "vscode-languageserver-types";
      version = "3.16.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-types/-/vscode-languageserver-types-3.16.0.tgz";
        sha512 = "k8luDIWJWyenLc5ToFQQMaSrqCHiLwyKPHKPQZ5zz21vM+vIVUSvsRpcbiECH4WR88K2XZqc4ScRcZ7nk/jbeA==";
      };
    };
    "vscode-uri-3.0.2" = {
      name = "vscode-uri";
      packageName = "vscode-uri";
      version = "3.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-uri/-/vscode-uri-3.0.2.tgz";
        sha512 = "jkjy6pjU1fxUvI51P+gCsxg1u2n8LSt0W6KrCNQceaziKzff74GoWmjVG46KieVzybO1sttPQmYfrwSHey7GUA==";
      };
    };
  };
in
{
  "@angular/language-server" = nodeEnv.buildNodePackage {
    name = "_at_angular_slash_language-server";
    packageName = "@angular/language-server";
    version = "13.1.0";
    src = fetchurl {
      url = "https://registry.npmjs.org/@angular/language-server/-/language-server-13.1.0.tgz";
      sha512 = "cqcKerH0qEa9ZUTvgl9ita+lfLY+8uRF7POVE6HlaRk9x6xAC4Hu2ZaFPrShmr8qqy0u0NyFVBh67kzSfAtndA==";
    };
    dependencies = [
      sources."@angular/language-service-13.1.0"
      sources."vscode-jsonrpc-6.0.0"
      sources."vscode-languageserver-7.0.0"
      sources."vscode-languageserver-protocol-3.16.0"
      sources."vscode-languageserver-types-3.16.0"
      sources."vscode-uri-3.0.2"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "LSP server for Angular Language Service";
      homepage = "https://github.com/angular/vscode-ng-language-service#readme";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
}