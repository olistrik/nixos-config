{ pkgs, ... }:

let
  makemd = pkgs.writeScriptBin "makemd" ''
    #!${pkgs.stdenv.shell}
    # This script is used to convert a set of .md files into a single pdf.
    # Files in the given file(s), or any .staging in the working directory,
    # will be concatonated into a single file then converted to a pdf using
    # pandoc. If a file in staging is not a .md file, it will be included in
    # an md code block.
    # The staging file should have one path from the working directory, per
    # line with no blank lines.
    TMP=._staging.md

    function print_usage() {
        echo Usage: $0 [FILE1 [FILE2 [FILE3 [...]]]]
    }

    function print_help () {
        print_usage
        echo 'If no file(s) is given, then any .staging files in the working
        directory will be used. Each file given will be treated as a seperate
        staging file, the resulting pdf(s) will be named FILENAME.pdf Existing
        files will be overwritten without warning.'
        exit 0
    }

    function concat_file () {
      cat $1 >> $TMP
      echo ''' >> $TMP
    }

    function concat_code () {
      FILE=$(basename -- $1)
      echo "### $FILE:" >> $TMP
      echo "\`\`\`{.$2 .numberLines startFrom=1}" >> $TMP
      concat_file $1
      echo '```' >> $TMP
    }

    function build_pdf () {
      if [ ! -f $1 ]
      then
        echo "Error: File $1 not found."
        print_help
      fi
      # delete tmp file if it exists.
      rm -rf $TMP
      while read line
      do
        if [[ $line == !* ]]
        then
          # staging line is a file include.
          first=$(echo "$line" | awk '{print $1}')
          file=''${first#\!*}


          #strip type off the !
          type=''${file#*.*}

          if [[ $(echo "$line" | wc -w) -gt 1 ]]
          then
            type=$(echo "$line" | awk '{print $2}')
          fi

          if [[ $type == md ]]
          then
            # it's markdown so we don't care about type.
            concat_file $file
          else
            # concat file and type.
            concat_code $file $type
          fi

        else
          # staging line is markdown.
          printf '%s\n' "$line" >> $TMP
        fi
      done < $1

      pandoc -f markdown-latex_macros -V geometry:margin=1in -o ''${1%.*}.pdf $TMP
      # cleanup
      #rm -rf $TMP
    }

    # Catch help option
    if [ $# -ge 1 ]
    then
      for ARG in $*
      do
        if [ $ARG == '-h' ]
        then
          print_help
        fi
      done
    fi

    # Stage all given files.
    for file in $*
    do
      build_pdf $file
    done

    # If no files are given stage staging.txt
    if [ $# -eq 0 ]
    then
      for file in $(ls *.makemd)
      do
        build_pdf $file
      done
    fi
  '';
in {
  environment.systemPackages = with pkgs; [
    makemd
  ];
}
