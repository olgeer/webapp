#!/bin/zsh

#------------configure------------
sftp_cmd_file="ftp_tmp.cmd"
sftp_server="olgeer.3322.org"
sftp_port="2225"
sftp_username="root"
sftp_path="/userdisk/data/web/webapp"
default_apk="app-release.apk"
local_file_path="./build/app/outputs/flutter-apk/app-release.apk"
setting_file_path="/web/setting.json"

#------------preAction------------
cfg=$(cat pubspec.yaml)
appname=$(echo $cfg|grep "name:"|sed 's/name: //g')
version=$(echo $cfg|grep "version:"|sed 's/version: //g')
apprelease=$(echo $appname"_"$version".apk")

#------------buildFtpCmd------------
rm $sftp_cmd_file
touch $sftp_cmd_file
echo "cd "$sftp_path >> $sftp_cmd_file
echo "rm "$apprelease >> $sftp_cmd_file
echo "put "$local_file_path" "$apprelease >> $sftp_cmd_file
echo "rm "$default_apk >> $sftp_cmd_file
echo "put "$local_file_path" "$default_apk >> $sftp_cmd_file

#------------modifySetting------------
#echo "get "$setting_file_path

echo "quit" >> $sftp_cmd_file

#------------connectFtp&RunCmd------------
sftp -P $sftp_port $sftp_username@$sftp_server < $sftp_cmd_file

#------------DeleteTempCmdFile------------
#rm $sftp_cmd_file
