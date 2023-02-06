{
  ansi = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14ims9zfal4gs2wpx2m5rd8zsrl2k794d359shkrsgg3fhr2a22l";
      type = "gem";
    };
    version = "1.5.0";
  };
  ast = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04nc8x27hlzlrr5c2gn7mar4vdr0apw5xg22wp6m8dx3wqr04a0y";
      type = "gem";
    };
    version = "2.4.2";
  };
  builder = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qibi5s67lpdv1wgcj66wcymcr04q6j4mzws6a479n0mlrmh5wr1";
      type = "gem";
    };
    version = "3.2.3";
  };
  metaclass = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hp99y2b1nh0nr8pc398n3f8lakgci6pkrg4bf2b2211j1f6hsc5";
      type = "gem";
    };
    version = "0.0.4";
  };
  minitest = {
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0w16p7cvslh3hxd3cia8jg4pd85z7rz7xqb16vh42gj4rijn8rmi";
      type = "gem";
    };
    version = "5.13.0";
  };
  minitest-reporters = {
    dependencies = ["ansi" "builder" "minitest" "ruby-progressbar"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0accficr4nyqfv0rjbmdir20qdl7hgyxlgwksb7adfy3h08mvrxp";
      type = "gem";
    };
    version = "1.4.2";
  };
  mocha = {
    dependencies = ["metaclass"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1s56iivmwpv4979hd25v3ghwwgy8ah15nh378lrj8czlh4kf5k5s";
      type = "gem";
    };
    version = "1.9.0";
  };
  parallel = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0055br0mibnqz0j8wvy20zry548dhkakws681bhj3ycb972awkzd";
      type = "gem";
    };
    version = "1.20.1";
  };
  parser = {
    dependencies = ["ast"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jixakyzmy0j5c1rb0fjrrdhgnyryvrr6vgcybs14jfw09akv5ml";
      type = "gem";
    };
    version = "3.0.0.0";
  };
  rainbow = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bb2fpjspydr6x0s8pn1pqkzmxszvkfapv0p4627mywl7ky4zkhk";
      type = "gem";
    };
    version = "3.0.0";
  };
  rake = {
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05l80mgaabdipkjsnjlffn9gc1wx9fi629d2kfbz8628cx3m6686";
      type = "gem";
    };
    version = "13.0.0";
  };
  regexp_parser = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vg7imjnfcqjx7kw94ccj5r78j4g190cqzi1i59sh4a0l940b9cr";
      type = "gem";
    };
    version = "2.1.1";
  };
  rexml = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08ximcyfjy94pm1rhcx04ny1vx2sk0x4y185gzn86yfsbzwkng53";
      type = "gem";
    };
    version = "3.2.5";
  };
  rubocop = {
    dependencies = ["parallel" "parser" "rainbow" "regexp_parser" "rexml" "rubocop-ast" "ruby-progressbar" "unicode-display_width"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zrzsgx35mcr81c51gyx63s7yngcfgk33dbkx5j0npkaks4fcm7r";
      type = "gem";
    };
    version = "1.11.0";
  };
  rubocop-ast = {
    dependencies = ["parser"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gkf1p8yal38nlvdb39qaiy0gr85fxfr09j5dxh8qvrgpncpnk78";
      type = "gem";
    };
    version = "1.4.1";
  };
  rubocop-minitest = {
    dependencies = ["rubocop"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "123kkqpcrk11hp5rylz3ayygd7aw39pwi3nhv850s3ymm34cckq6";
      type = "gem";
    };
    version = "0.11.0";
  };
  rubocop-performance = {
    dependencies = ["rubocop"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nwrb19arap4r2mhrjc35rzydv6pn361vq44nl3glg4w4lwni75y";
      type = "gem";
    };
    version = "1.5.0";
  };
  rubocop-rake = {
    dependencies = ["rubocop"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04q3qa9qnzm70yqay0qxc41a8v166apc8172f7jfvswx38akhnxw";
      type = "gem";
    };
    version = "0.5.1";
  };
  rubocop-shopify = {
    dependencies = ["rubocop"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lbnglg3s5jkgsx44zc2mym6ffvlk7hapxia1scyif0arji542hg";
      type = "gem";
    };
    version = "2.0.1";
  };
  ruby-progressbar = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02nmaw7yx9kl7rbaan5pl8x5nn0y4j5954mzrkzi9i3dhsrps4nc";
      type = "gem";
    };
    version = "1.11.0";
  };
  unicode-display_width = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bilbnc8j6jkb59lrf177i3p1pdyxll0n8400hzqr35vl3r3kv2m";
      type = "gem";
    };
    version = "2.0.0";
  };
}
