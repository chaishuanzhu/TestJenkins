# Jenkins 持续集成测试

参考：
https://www.jianshu.com/p/41ecb06ae95f.  
https://juejin.im/post/5ad6beff6fb9a028c06b5889.  
https://www.runoob.com/linux/linux-shell.html  
https://github.com/chaishuanzhu/iOSShell.    

## 1.安装Jenkins
```
brew install jenkins
```

## 2.启动和停止
```
jenkins server

brew services start jenkins

brew services restart jenkins

brew services stop jenkins
```

## 3.安装插件 
建议选择 Install suggested plugins。  
登录 http://localhost:8080 ，选择“系统管理”——“管理插件”,在“可选插件”中选中“GitLab Plugin”、“Gitlab Hook Plugin”、“Xcode integration"等常用插件，然后安装。

## 4.创建项目
参考链接 
## 5.sh脚本
```
echo "执行pod install"
pod install
echo "pod 执行完毕"
echo "开始下载依赖"
# wget -p $WORKSPACE/Frameworks http://127.0.0.1/xxxx.framework
```

```
BUILD_TYPE="Release"
SCHEME_NAME="TestJenkins"

# 上传到蒲公英
PGYER_U_KEY="44a10b958afa3846268912d695d2a44e"
PGYER_API_KEY="b4656bb3b89d68836bab2258666ec1ed"


# 编译生成文件目录
EXPORT_PATH="$WORKSPACE/build"

# 指定输出文件目录不存在则创建
if test -d "$EXPORT_PATH" ; then
echo ">>>>>>>>>>>>>>>>>>>保存归档文件和ipa的路径=$EXPORT_PATH "
rm -rf $EXPORT_PATH
else
mkdir -pv $EXPORT_PATH
fi

# 归档文件路径

EXPORT_ARCHIVE_PATH="$EXPORT_PATH/$SCHEME_NAME.xcarchive"
# ipa 导出路径
EXPORT_IPA_PATH="$EXPORT_PATH"

echo ">>>>>>>>>>>>>>>>>>>开始构建项目，当前选择构建类型：" + $BUILD_TYPE 
echo ">>>>>>>>>>>>>>>>>>>当前 workspace " +$WORKSPACE
if [ $BUILD_TYPE == "Release"]; 
then 
	xcodebuild archive -workspace $WORKSPACE/$SCHEME_NAME.xcworkspace -archivePath $EXPORT_ARCHIVE_PATH -sdk iphoneos -scheme $SCHEME_NAME -configuration Release
else 
	xcodebuild archive -workspace $WORKSPACE/$SCHEME_NAME.xcworkspace -archivePath $EXPORT_ARCHIVE_PATH -sdk iphoneos -scheme $SCHEME_NAME -configuration Debug
fi

# 检查是否构建成功
# xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if test -d "$EXPORT_ARCHIVE_PATH" ; then
echo ">>>>>>>>>>>>>>>>>>>项目构建成功 🚀 🚀 🚀 "
else
echo ">>>>>>>>>>>>>>>>>>>项目构建失败 😢 😢 😢 "
exit 1
fi

echo ">>>>>>>>>>>>>>>>>>>开始导出ipa文件 "
xcodebuild -exportArchive -archivePath $EXPORT_ARCHIVE_PATH -exportPath $EXPORT_IPA_PATH -exportOptionsPlist $WORKSPACE/build/AdHocExportOptionsPlist.plist -allowProvisioningUpdates

# 检查文件是否存在
if test -f "$EXPORT_IPA_PATH/$SCHEME_NAME.ipa" ; then
echo ">>>>>>>>>>>>>>>>>>>导出 $EXPORT_IPA_PATH/$SCHEME_NAME.ipa 包成功 🎉 🎉 🎉 "
fi

# 上传到蒲公英
curl -F "file=@$EXPORT_IPA_PATH/$SCHEME_NAME.ipa" \
-F "uKey=$PGYER_U_KEY" \
-F "_api_key=$PGYER_API_KEY" \
"http://www.pgyer.com/apiv1/app/upload"

echo " 上传 $SCHEME_NAME.ipa 包 到 pgyer 成功 🎉 🎉 🎉 "
```