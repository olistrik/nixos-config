VIVALDI=$(ls -d /nix/store/*/ | grep vivaldi)
if [ $? -eq 0 ] ; then
  VIVALDI=$(echo $VIVALDI | sed 's:/*$::')
  echo found Vivaldi at $VIVALDI
  echo Updating ffmpeg...
  ${VIVALDI}/opt/vivaldi/update-ffmpeg
  echo Updating widevine...
  ${VIVALDI}/opt/vivaldi/update-widevine
  echo Done!
else
  echo Vivaldi store not found. Check it is installed?
fi
