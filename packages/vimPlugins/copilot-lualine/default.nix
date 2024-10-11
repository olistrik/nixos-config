{ vimUtils, fetchFromGitHub }: vimUtils.buildVimPlugin {
  name = "copilot-lualine";
  src = fetchFromGitHub {
    owner = "AndreM222";
    repo = "copilot-lualine";
    rev = "f40450c3e138766026327e7807877ea860618258";
    hash = "sha256-PXiJ7rdlE8J93TFtu+D+8398Wg7DhK7EZ0Aw4JDoqWM=";
  };
}

